import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/azuracast_api.dart';
import '../components/app_constants.dart';
import '../components/app_snackbar.dart';
import '../models/radiomodel/downloaded_episode_model.dart';
import '../models/radiomodel/podcast_episode_model.dart';
import 'audio_player_controller.dart';
import 'episode_progress_controller.dart';
import 'settings_controller.dart';

enum DownloadStatus { waiting, waitingForWifi, downloading, paused, failed }

/// A queued, in-flight or failed download.
class DownloadTask {
  DownloadTask(this.episode, this.showTitle, {this.quiet = false});

  final PodcastEpisode episode;
  final String showTitle;

  /// Part of a "Download all": no per-episode snackbars.
  final bool quiet;
  DownloadStatus status = DownloadStatus.waiting;
  int received = 0;
  int? total;

  /// Set by "Download now" to skip the Wi-Fi-only rule.
  bool allowCellular = false;

  http.Client? _client;
  bool _stopRequested = false;

  /// Queued, running or paused; not failed.
  bool get active => status != DownloadStatus.failed;

  /// 0..1, or null when the size is unknown.
  double? get fraction =>
      total == null || total! <= 0 ? null : (received / total!).clamp(0, 1);
}

/// Device storage, for the Downloads storage card.
class StorageInfo {
  const StorageInfo({required this.free, required this.total});
  final int free;
  final int total;
}

/// Downloads podcast episodes to app storage for offline listening, two at
/// a time. Paused downloads resume where they stopped; downloads cut off by
/// closing the app are discarded. Failed ones stay listed until retried or
/// cancelled.
class DownloadController extends GetxController {
  /// The parameters exist for tests.
  DownloadController({
    http.Client Function()? client,
    Future<Directory> Function()? directory,
    void Function(String message,
            {String? actionLabel, VoidCallback? onAction})?
        notify,
    Future<bool> Function()? onWifi,
    DateTime Function()? clock,
    Future<StorageInfo?> Function()? storage,
  })  : _storageInfo = storage,
        _newClient = client ?? http.Client.new,
        _directory = directory ?? _defaultDirectory,
        _notify = notify ?? _snackbar,
        _onWifi = onWifi ?? _defaultOnWifi,
        _now = clock ?? DateTime.now;

  static const _prefsKey = 'podcast_downloads';
  static const maxConcurrent = 2;
  static const _storageChannel = MethodChannel('tv.avventomedia.app/storage');

  final http.Client Function() _newClient;
  final Future<Directory> Function() _directory;
  final void Function(String message,
      {String? actionLabel, VoidCallback? onAction}) _notify;
  final Future<bool> Function() _onWifi;
  final DateTime Function() _now;
  final Future<StorageInfo?> Function()? _storageInfo;

  /// Finished downloads by episode id.
  final RxMap<String, DownloadedEpisode> downloads =
      <String, DownloadedEpisode>{}.obs;

  /// Queued and in-flight downloads, in queue order.
  final RxMap<String, DownloadTask> tasks = <String, DownloadTask>{}.obs;

  /// "Pause all" is on.
  final RxBool paused = false.obs;

  final Set<String> _running = {};
  StreamSubscription? _connectivitySub;
  AppLifecycleListener? _lifecycle;
  late final Future<void> ready;

  /// Shown inside the full player when it's open, so it isn't hidden.
  static void _snackbar(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    final player = Get.isRegistered<AudioPlayerController>()
        ? Get.find<AudioPlayerController>()
        : null;
    final inPlayer = (player?.panelPercentage.value ?? 0) > 0.5;
    AppSnackbar.show(message,
        actionLabel: actionLabel,
        onAction: onAction,
        navigator: inPlayer ? player!.fullPlayerNavigator : null);
  }

  static Future<Directory> _defaultDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/podcasts');
  }

  /// Unknown counts as Wi-Fi, so a plugin failure never blocks downloads.
  static Future<bool> _defaultOnWifi() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);
    } catch (_) {
      return true;
    }
  }

  SettingsController? get _settings => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : null;

  @override
  void onInit() {
    super.onInit();
    ready = _load();
    final settings = _settings;
    if (settings != null) {
      ever(settings.removePlayed, (_) => removePlayed());
      ever(settings.downloadWifiOnly, (_) => _pump());
    }
    // Re-check "Remove played" whenever the app comes back.
    _lifecycle = AppLifecycleListener(onResume: removePlayed);
  }

  @override
  void onReady() {
    super.onReady();
    // Retry Wi-Fi-only downloads when the connection changes.
    try {
      _connectivitySub = Connectivity()
          .onConnectivityChanged
          .listen((_) => _pump(), onError: (_) {});
    } catch (_) {
      // No platform plugin (tests).
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final items = (json.decode(raw) as List)
          .map((e) => DownloadedEpisode.fromJson(e))
          // Files can be cleared from outside the app.
          .where((d) => File(d.filePath).existsSync());
      downloads.assignAll({for (final d in items) d.episode.id: d});
    }
    // Leftovers from downloads cut off when the app was closed.
    final dir = await _directory();
    if (dir.existsSync()) {
      for (final f in dir.listSync().whereType<File>()) {
        if (f.path.endsWith('.part')) f.deleteSync();
      }
    }
    await removePlayed();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey,
        json.encode(downloads.values.map((d) => d.toJson()).toList()));
  }

  bool isDownloaded(String id) => downloads.containsKey(id);

  /// Queued, running, paused or failed.
  bool isQueued(String id) => tasks.containsKey(id);
  bool isFailed(String id) => tasks[id]?.status == DownloadStatus.failed;

  /// Local file for [id], or null when it isn't downloaded.
  String? localPath(String id) => downloads[id]?.filePath;

  /// Newest download first.
  List<DownloadedEpisode> get sorted => downloads.values.toList()
    ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));

  int get totalBytes => downloads.values.fold(0, (sum, d) => sum + d.bytes);

  /// Queues [episode], or retries it if it failed. With Wi-Fi only on and
  /// no Wi-Fi it waits, and the snackbar offers "Download now".
  Future<void> download(PodcastEpisode episode, {required String showTitle}) =>
      _enqueue([episode], showTitle, quiet: false);

  /// Queues every episode not yet downloaded or queued, with no
  /// per-episode snackbars.
  Future<void> enqueueAll(Iterable<PodcastEpisode> episodes,
          {required String showTitle}) =>
      _enqueue(episodes, showTitle, quiet: true);

  Future<void> _enqueue(Iterable<PodcastEpisode> episodes, String showTitle,
      {required bool quiet}) async {
    final added = <String>[];
    for (final episode in episodes) {
      final id = episode.id;
      if (isFailed(id)) {
        tasks[id]!.status = DownloadStatus.waiting;
      } else if (isDownloaded(id) || isQueued(id)) {
        continue;
      } else {
        tasks[id] = DownloadTask(episode, showTitle, quiet: quiet);
      }
      added.add(id);
    }
    if (added.isEmpty) return;
    tasks.refresh();
    if (_wifiOnly && !await _onWifi()) {
      _notify(AppConstants.waitingForWifi,
          actionLabel: AppConstants.downloadNow,
          onAction: () => added.forEach(downloadNow));
    }
    _pump();
  }

  /// Tries a failed download again.
  void retry(String id) {
    final task = tasks[id];
    if (task == null || task.active) return;
    task.status = DownloadStatus.waiting;
    tasks.refresh();
    _pump();
  }

  /// Lets [id] use mobile data despite Wi-Fi only.
  void downloadNow(String id) {
    final task = tasks[id];
    if (task == null) return;
    task.allowCellular = true;
    if (task.status == DownloadStatus.waitingForWifi) {
      task.status = DownloadStatus.waiting;
    }
    tasks.refresh();
    _pump();
  }

  bool get _wifiOnly => _settings?.downloadWifiOnly.value ?? false;

  bool _pumping = false;
  bool _pumpAgain = false;

  /// Starts queued downloads while fewer than [maxConcurrent] are running.
  Future<void> _pump() async {
    if (_pumping) {
      _pumpAgain = true; // Don't drop a wake-up that lands mid-pump.
      return;
    }
    _pumping = true;
    try {
      do {
        _pumpAgain = false;
        await ready;
        if (paused.value || _running.length >= maxConcurrent) break;
        final onWifi = await _onWifi();
        for (final task in tasks.values.toList()) {
          if (_running.length >= maxConcurrent) break;
          final id = task.episode.id;
          if (_running.contains(id) ||
              task.status == DownloadStatus.paused ||
              task.status == DownloadStatus.failed) {
            continue;
          }
          if (_wifiOnly && !onWifi && !task.allowCellular) {
            task.status = DownloadStatus.waitingForWifi;
            continue;
          }
          _running.add(id);
          unawaited(_run(task));
        }
        tasks.refresh();
      } while (_pumpAgain);
    } finally {
      _pumping = false;
    }
  }

  Future<void> _run(DownloadTask task) async {
    final id = task.episode.id;
    task._stopRequested = false;
    task.status = DownloadStatus.downloading;
    tasks.refresh();
    final client = task._client = _newClient();
    final dir = await _directory();
    await dir.create(recursive: true);
    final name = id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final part = File('${dir.path}/$name.part');
    var finished = false;

    try {
      final request = http.Request('GET', Uri.parse(task.episode.downloadLink))
        ..headers.addAll(
            AzuraCastAPI.mediaHeaders(task.episode.downloadLink) ?? const {});
      final resumeFrom = part.existsSync() ? part.lengthSync() : 0;
      if (resumeFrom > 0) request.headers['Range'] = 'bytes=$resumeFrom-';
      final response = await client.send(request);
      final resumed = response.statusCode == 206 && resumeFrom > 0;
      if (response.statusCode != 200 && !resumed) {
        throw HttpException('HTTP ${response.statusCode}');
      }
      task.received = resumed ? resumeFrom : 0;
      final length = response.contentLength;
      task.total = length == null ? null : length + task.received;

      final sink =
          part.openWrite(mode: resumed ? FileMode.append : FileMode.write);
      var lastShown = task.fraction ?? 0;
      try {
        await for (final chunk in response.stream) {
          if (task._stopRequested) break;
          sink.add(chunk);
          task.received += chunk.length;
          // Redraw per whole percent, not per chunk.
          final f = task.fraction ?? 0;
          if (f - lastShown >= 0.01 || task.total == null) {
            lastShown = f;
            tasks.refresh();
          }
        }
      } finally {
        await sink.close();
      }
      if (task._stopRequested) return; // Paused or cancelled; see _stop.

      final file = await part.rename('${dir.path}/$name.mp3');
      downloads[id] = DownloadedEpisode(
        episode: task.episode,
        showTitle: task.showTitle,
        filePath: file.path,
        bytes: task.received,
        downloadedAt: _now(),
      );
      finished = true;
      await _save();
      if (!task.quiet) _notify(AppConstants.downloaded(task.episode.title));
    } catch (_) {
      if (!task._stopRequested) {
        if (part.existsSync()) part.deleteSync();
        task.status = DownloadStatus.failed;
        if (!task.quiet) {
          _notify(AppConstants.downloadFailed(task.episode.title));
        }
      }
    } finally {
      client.close();
      task._client = null;
      _running.remove(id);
      if (finished) tasks.remove(id);
      tasks.refresh();
      _pump();
    }
  }

  /// Stops a running download, keeping its partial file for resume.
  void _stop(DownloadTask task) {
    if (!_running.contains(task.episode.id)) return;
    task._stopRequested = true;
    task._client?.close(); // Aborts the response stream.
  }

  void pauseAll() {
    paused.value = true;
    for (final t in tasks.values) {
      if (!t.active) continue;
      t.status = DownloadStatus.paused;
      _stop(t);
    }
    tasks.refresh();
  }

  void resumeAll() {
    paused.value = false;
    for (final t in tasks.values) {
      if (t.status == DownloadStatus.paused) t.status = DownloadStatus.waiting;
    }
    tasks.refresh();
    _pump();
  }

  Future<void> cancelAll(Iterable<String> ids) =>
      Future.wait(ids.toList().map(cancel));

  /// Drops a queued, running or failed download and its partial file.
  Future<void> cancel(String id) async {
    final task = tasks.remove(id);
    if (task == null) return;
    _stop(task);
    final dir = await _directory();
    final name = id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    // Let the running stream close its sink first.
    await Future<void>.delayed(Duration.zero);
    final part = File('${dir.path}/$name.part');
    if (part.existsSync()) part.deleteSync();
  }

  Future<void> remove(String id) => removeAll([id]);

  /// Deletes downloads; one snackbar for the lot.
  Future<void> removeAll(Iterable<String> ids, {bool quiet = false}) async {
    final removed = <DownloadedEpisode>[];
    for (final id in ids.toList()) {
      final item = downloads.remove(id);
      if (item == null) continue;
      final file = File(item.filePath);
      if (file.existsSync()) await file.delete();
      removed.add(item);
    }
    if (removed.isEmpty) return;
    await _save();
    if (quiet) return;
    _notify(removed.length == 1
        ? AppConstants.downloadRemoved(removed.single.episode.title)
        : AppConstants.downloadsRemoved(removed.length));
  }

  /// Applies "Remove played": deletes downloads finished longer ago than
  /// the setting, except the one loaded in the player.
  Future<void> removePlayed() async {
    final after = _settings?.removePlayed.value.after;
    if (after == null || !Get.isRegistered<EpisodeProgressController>()) {
      return;
    }
    final progress = Get.find<EpisodeProgressController>();
    final now = _now();
    final stale = downloads.keys.where((id) {
      final p = progress.of(id);
      return p.played &&
          p.playedAt != null &&
          now.difference(p.playedAt!) >= after &&
          id != _loadedEpisodeId;
    });
    await removeAll(stale, quiet: true);
  }

  String? get _loadedEpisodeId => Get.isRegistered<EpisodeProgressController>()
      ? Get.find<EpisodeProgressController>().currentId
      : null;

  /// Free and total device storage, or null where unsupported.
  Future<StorageInfo?> storage() async {
    final injected = _storageInfo;
    if (injected != null) return injected();
    try {
      final info =
          await _storageChannel.invokeMapMethod<String, int>('storage');
      if (info == null) return null;
      return StorageInfo(free: info['free']!, total: info['total']!);
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    _lifecycle?.dispose();
    tasks.values.forEach(_stop);
    super.onClose();
  }
}

/// "12.4 MB" style size.
String formatBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} KB';
  final mb = bytes / (1024 * 1024);
  if (mb < 1024) return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  return '${(mb / 1024).toStringAsFixed(1)} GB';
}
