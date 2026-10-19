import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/radiomodel/podcast_episode_model.dart';
import 'audio_player_controller.dart';
import 'podcast_episode_controller.dart';

/// Where the listener got to in one episode.
class EpisodeProgress {
  const EpisodeProgress({
    this.position = Duration.zero,
    this.duration,
    this.played = false,
    this.playedAt,
  });

  final Duration position;
  final Duration? duration;
  final bool played;

  /// When it was last finished; drives "Remove played".
  final DateTime? playedAt;

  /// 0..1, or 0 when the length is unknown.
  double get fraction {
    final d = duration;
    if (played) return 1;
    if (d == null || d.inMilliseconds == 0) return 0;
    return (position.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
  }

  Duration? get remaining => duration == null ? null : duration! - position;

  /// Stamps [playedAt] when [played] turns on, clears it when off.
  EpisodeProgress copyWith(
      {Duration? position, Duration? duration, bool? played}) {
    final isPlayed = played ?? this.played;
    return EpisodeProgress(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      played: isPlayed,
      playedAt: !isPlayed ? null : (this.played ? playedAt : DateTime.now()),
    );
  }

  factory EpisodeProgress.fromJson(Map<String, dynamic> json) =>
      EpisodeProgress(
        position: Duration(milliseconds: json['p'] ?? 0),
        duration: json['d'] == null ? null : Duration(milliseconds: json['d']),
        played: json['x'] ?? false,
        playedAt: json['t'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['t']),
      );

  Map<String, dynamic> toJson() => {
        'p': position.inMilliseconds,
        if (duration != null) 'd': duration!.inMilliseconds,
        if (played) 'x': true,
        if (playedAt != null) 't': playedAt!.millisecondsSinceEpoch,
      };
}

/// An episode you listened to, with the show it came from.
class RecentEpisode {
  const RecentEpisode(this.episode, this.showTitle);

  final PodcastEpisode episode;
  final String showTitle;

  factory RecentEpisode.fromJson(Map<String, dynamic> json) => RecentEpisode(
      PodcastEpisode.fromJson(Map<String, dynamic>.from(json['e'])),
      json['s'] ?? '');

  Map<String, dynamic> toJson() => {'e': episode.toJson(), 's': showTitle};
}

/// Remembers resume position, length and played state per podcast episode,
/// following the shared player. Live radio is ignored.
class EpisodeProgressController extends GetxController {
  EpisodeProgressController({AudioPlayerController? player})
      : _injectedPlayer = player;

  static const _prefsKey = 'episode_progress';
  static const _recentsKey = 'episode_recents';

  /// Episodes kept for "Continue listening".
  static const _maxRecents = 20;

  /// Saved every this often while playing, and on pause.
  static const _saveEvery = Duration(seconds: 5);

  /// Closer than this to the end counts as played.
  static const _endSlack = Duration(seconds: 20);

  final AudioPlayerController? _injectedPlayer;
  late final AudioPlayerController _player;
  final RxMap<String, EpisodeProgress> progress =
      <String, EpisodeProgress>{}.obs;
  /// Most recently listened first.
  final RxList<RecentEpisode> recents = <RecentEpisode>[].obs;
  final List<StreamSubscription> _subs = [];
  late final Future<void> ready;

  @override
  void onInit() {
    super.onInit();
    _player = _injectedPlayer ?? Get.find<AudioPlayerController>();
    ready = _load();
    final audio = _player.audioPlayer;
    _subs.add(audio.positionStream.listen(_onPosition));
    _subs.add(audio.playerStateStream.listen(_onState));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final map = (json.decode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, EpisodeProgress.fromJson(v)));
      // Keep anything recorded while loading.
      progress.assignAll({...map, ...progress});
    }
    final saved = prefs.getString(_recentsKey);
    if (saved != null) {
      try {
        final loaded = [
          for (final r in json.decode(saved) as List)
            RecentEpisode.fromJson(Map<String, dynamic>.from(r))
        ];
        final newer = recents.map((r) => r.episode.id).toSet();
        recents.addAll(loaded.where((r) => !newer.contains(r.episode.id)));
      } catch (_) {
        // A bad list just means an empty "Continue listening".
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey,
        json.encode(progress.map((k, v) => MapEntry(k, v.toJson()))));
  }

  /// Read from the player's sequence, which changes in step with position
  /// (currentMediaItem lags a microtask behind on auto-advance).
  /// The loaded podcast episode, if any.
  String? get currentId => _currentId;

  String? get _currentId {
    if (_player.isLive.value) return null;
    final tag = _player.audioPlayer.sequenceState.currentSource?.tag;
    return tag is MediaItem ? tag.id : _player.currentMediaItem?.id;
  }

  void _onPosition(Duration position) {
    final id = _currentId;
    if (id == null) return;
    final old = progress[id] ?? const EpisodeProgress();
    final duration = _player.audioPlayer.duration ?? old.duration;
    final nearEnd = duration != null &&
        duration > _endSlack &&
        position >= duration - _endSlack;
    final moved = (position - old.position).abs() >= _saveEvery;
    if (!moved && duration == old.duration && nearEnd == old.played) return;
    _record(
        id,
        old.copyWith(
          position: position,
          duration: duration,
          // Listening again past the start clears "played".
          played: nearEnd || (old.played && position < _saveEvery),
        ));
  }

  void _onState(PlayerState state) {
    final id = _currentId;
    if (id == null) return;
    final old = progress[id] ?? const EpisodeProgress();
    if (state.processingState == ProcessingState.completed) {
      _record(id, old.copyWith(position: Duration.zero, played: true));
    } else if (!state.playing &&
        state.processingState == ProcessingState.ready) {
      // Paused: keep the exact spot.
      _record(id, old.copyWith(position: _player.audioPlayer.position));
    }
  }

  void _record(String id, EpisodeProgress value) {
    runOutsideBuild(() {
      progress[id] = value;
      _save();
      _remember(id);
    });
  }

  /// Puts the playing episode first in [recents].
  void _remember(String id) {
    if (recents.isNotEmpty && recents.first.episode.id == id) return;
    if (!Get.isRegistered<PodcastEpisodeController>()) return;
    final queue = Get.find<PodcastEpisodeController>();
    final episode = queue.queued(id);
    if (episode == null) return;
    recents
      ..removeWhere((r) => r.episode.id == id)
      ..insert(0, RecentEpisode(episode, queue.queueShowTitle));
    if (recents.length > _maxRecents) {
      recents.removeRange(_maxRecents, recents.length);
    }
    SharedPreferences.getInstance().then((prefs) => prefs.setString(
        _recentsKey, json.encode([for (final r in recents) r.toJson()])));
  }

  /// Part-listened episodes, most recent first.
  List<RecentEpisode> get continueListening => [
        for (final r in recents)
          if (_inProgress(of(r.episode.id))) r
      ];

  static bool _inProgress(EpisodeProgress p) =>
      !p.played &&
      p.position >= const Duration(seconds: 10) &&
      p.fraction < 1;

  EpisodeProgress of(String id) => progress[id] ?? const EpisodeProgress();

  bool isPlayed(String id) => of(id).played;

  /// Where to start [id] from, or null to start at the beginning.
  Duration? resumePosition(String id) {
    final p = of(id);
    if (p.played || p.position < const Duration(seconds: 10)) return null;
    return p.position;
  }

  void setPlayed(String id, bool played) {
    final old = of(id);
    progress[id] = old.copyWith(position: Duration.zero, played: played);
    _save();
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }
}
