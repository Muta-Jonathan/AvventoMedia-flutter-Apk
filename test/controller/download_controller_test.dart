import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/download_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
import 'package:avvento_media/controller/settings_controller.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';
import '../helpers/fake_push_notifications.dart';

PodcastEpisode episode(String id) => PodcastEpisode(
      id: id,
      title: 'Episode $id',
      description: '',
      playlistMediaArtist: '',
      playlistMediaAlbum: '',
      publishedAt: 0,
      downloadLink: 'https://example.org/$id.mp3',
      publicLink: '',
      isPublished: true,
      art: '',
      media: '',
    );

void main() {
  late Directory dir;
  late List<String> messages;
  late VoidCallback? lastAction;
  late bool wifi;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('downloads_test');
    messages = [];
    lastAction = null;
    wifi = true;
  });

  tearDown(() {
    Get.reset();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  DownloadController create(http.Client Function() client,
          {DateTime Function()? clock}) =>
      Get.put(DownloadController(
        client: client,
        directory: () async => dir,
        notify: (m, {actionLabel, onAction}) {
          messages.add(m);
          lastAction = onAction;
        },
        onWifi: () async => wifi,
        clock: clock,
      ));

  MockClient bytes(int n) =>
      MockClient((_) async => http.Response.bytes(List.filled(n, 7), 200));

  /// Waits until nothing is queued or running (failed ones stay listed).
  /// Waits for [condition] in real time. File I/O and the queue run on real
  /// timers, so a fixed pause is too short on a slow CI machine.
  Future<void> until(bool Function() condition) async {
    for (var i = 0; i < 1000 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  Future<void> settle(DownloadController d) =>
      until(() => !d.tasks.values.any((t) => t.active));

  Future<SettingsController> settings() async {
    final s = Get.put(await SettingsController.load(push: FakePushNotifications()));
    return s;
  }

  test('saves the file, remembers it and reports it', () async {
    final downloads = create(() => bytes(1000));

    await downloads.download(episode('a'), showTitle: 'Show');
    await settle(downloads);

    expect(downloads.isDownloaded('a'), isTrue);
    expect(downloads.isQueued('a'), isFalse);
    final file = File(downloads.localPath('a')!);
    expect(file.lengthSync(), 1000);
    expect(downloads.downloads['a']!.showTitle, 'Show');
    expect(messages.single, contains('Episode a'));

    // Survives a restart.
    Get.delete<DownloadController>();
    final reloaded = create(http.Client.new);
    await reloaded.ready;
    expect(reloaded.localPath('a'), file.path);
  });

  test('runs two downloads at a time, in queue order', () async {
    final started = <String>[];
    final bodies = <String, StreamController<List<int>>>{};
    final downloads = create(() => MockClient.streaming((r, _) async {
          final name = r.url.pathSegments.last;
          started.add(name);
          final body = bodies[name] = StreamController<List<int>>();
          return http.StreamedResponse(body.stream, 200, contentLength: 3);
        }));

    for (final id in ['a', 'b', 'c']) {
      await downloads.download(episode(id), showTitle: 'Show');
    }
    await until(() => started.length >= 2);
    // Give a wrongly started third download the chance to show up.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    // Two run at once; which request goes out first isn't defined.
    expect(started.toSet(), {'a.mp3', 'b.mp3'});
    expect(downloads.tasks['c']!.status, DownloadStatus.waiting);

    bodies['a.mp3']!
      ..add([1, 2, 3])
      ..close();
    await until(() => started.length >= 3);
    // The queued one starts once a slot frees up, and last.
    expect(started.last, 'c.mp3');
    expect(started.toSet(), {'a.mp3', 'b.mp3', 'c.mp3'});

    for (final name in ['b.mp3', 'c.mp3']) {
      bodies[name]!
        ..add([1, 2, 3])
        ..close();
    }
    await settle(downloads);
    expect(downloads.downloads.keys, containsAll(['a', 'b', 'c']));
  });

  test('a failed download stays listed as failed and can be retried',
      () async {
    var fail = true;
    final downloads = create(() => MockClient((_) async => fail
        ? http.Response('', 404)
        : http.Response.bytes([1, 2, 3], 200)));

    await downloads.download(episode('a'), showTitle: 'Show');
    await settle(downloads);

    expect(downloads.isDownloaded('a'), isFalse);
    expect(downloads.isFailed('a'), isTrue);
    expect(dir.listSync(), isEmpty);
    expect(messages.single, startsWith("Couldn't download"));

    fail = false;
    downloads.retry('a');
    await settle(downloads);
    expect(downloads.isDownloaded('a'), isTrue);
    expect(downloads.tasks, isEmpty);
  });

  test('enqueueAll downloads every episode without per-episode messages',
      () async {
    final downloads = create(() => bytes(10));
    await downloads.download(episode('a'), showTitle: 'Show');
    await settle(downloads);
    messages.clear();

    await downloads.enqueueAll([episode('a'), episode('b'), episode('c')],
        showTitle: 'Show');
    await settle(downloads);

    expect(downloads.downloads.keys, containsAll(['a', 'b', 'c']));
    expect(messages, isEmpty);
  });

  test('cancelAll stops queued and running downloads', () async {
    final downloads = create(() => MockClient.streaming((_, __) async =>
        http.StreamedResponse(StreamController<List<int>>().stream, 200,
            contentLength: 100)));

    await downloads.enqueueAll([episode('a'), episode('b'), episode('c')],
        showTitle: 'Show');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(downloads.tasks.length, 3);

    await downloads.cancelAll(['a', 'b', 'c']);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(downloads.tasks, isEmpty);
    expect(dir.listSync(), isEmpty);
    expect(messages, isEmpty);
  });

  test('pause keeps the partial file; resume asks for the rest', () async {
    final body = StreamController<List<int>>();
    final ranges = <String?>[];
    final downloads = create(() => MockClient.streaming((r, _) async {
          ranges.add(r.headers['Range']);
          if (ranges.length == 1) {
            return http.StreamedResponse(body.stream, 200, contentLength: 100);
          }
          return http.StreamedResponse(
              Stream.value(List.filled(60, 2)), 206,
              contentLength: 60);
        }));

    await downloads.download(episode('a'), showTitle: 'Show');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    body.add(List.filled(40, 1));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(downloads.tasks['a']!.fraction, 0.4);

    downloads.pauseAll();
    await body.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(downloads.tasks['a']!.status, DownloadStatus.paused);
    expect(messages, isEmpty);

    downloads.resumeAll();
    await settle(downloads);

    expect(ranges, [null, 'bytes=40-']);
    expect(File(downloads.localPath('a')!).lengthSync(), 100);
  });

  test('cancel stops it quietly and discards the partial file', () async {
    final body = StreamController<List<int>>();
    final downloads = create(() => MockClient.streaming((_, __) async =>
        http.StreamedResponse(body.stream, 200, contentLength: 100)));

    await downloads.download(episode('a'), showTitle: 'Show');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    body.add(List.filled(50, 1));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await downloads.cancel('a');
    await body.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(downloads.isDownloaded('a'), isFalse);
    expect(downloads.tasks, isEmpty);
    expect(dir.listSync(), isEmpty);
    expect(messages, isEmpty);
  });

  test('Wi-Fi only waits off Wi-Fi; "Download now" goes ahead', () async {
    await settings();
    wifi = false;
    final downloads = create(() => bytes(10));

    await downloads.download(episode('a'), showTitle: 'Show');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(downloads.tasks['a']!.status, DownloadStatus.waitingForWifi);
    expect(lastAction, isNotNull);

    lastAction!();
    await settle(downloads);
    expect(downloads.isDownloaded('a'), isTrue);
  });

  test('Remove played deletes downloads played long enough ago', () async {
    final s = await settings();
    Get.put(AudioPlayerController(
        player: FakeAudioPlayer(), startAudioService: false));
    final progress = Get.put(EpisodeProgressController());
    var now = DateTime.now();
    final downloads = create(() => bytes(10), clock: () => now);
    await downloads.download(episode('a'), showTitle: 'Show');
    await downloads.download(episode('b'), showTitle: 'Show');
    await settle(downloads);

    progress.setPlayed('a', true);
    await s.setRemovePlayed(RemovePlayed.day);
    await downloads.removePlayed();
    expect(downloads.isDownloaded('a'), isTrue); // Not 24h yet.

    now = now.add(const Duration(hours: 25));
    await downloads.removePlayed();
    expect(downloads.isDownloaded('a'), isFalse);
    expect(downloads.isDownloaded('b'), isTrue); // Unplayed stays.
  });

  test('removeAll deletes the files with one message', () async {
    final downloads = create(() => bytes(10));
    await downloads.download(episode('a'), showTitle: 'Show');
    await downloads.download(episode('b'), showTitle: 'Show');
    await settle(downloads);
    final paths = [downloads.localPath('a')!, downloads.localPath('b')!];
    messages.clear();

    await downloads.removeAll(['a', 'b']);

    expect(paths.map((p) => File(p).existsSync()), everyElement(isFalse));
    expect(downloads.downloads, isEmpty);
    expect(messages, ['Removed 2 downloads']);
  });

  test('forgets downloads whose file is gone', () async {
    final downloads = create(() => bytes(10));
    await downloads.download(episode('a'), showTitle: 'Show');
    await settle(downloads);
    File(downloads.localPath('a')!).deleteSync();

    Get.delete<DownloadController>();
    final reloaded = create(http.Client.new);
    await reloaded.ready;
    expect(reloaded.downloads, isEmpty);
  });
}
