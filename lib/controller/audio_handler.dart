import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler {
  final AudioPlayer _player;

  MediaItem? _currentItem;

  MyAudioHandler(this._player) {
    // Track changes in the current sequence item (playlist navigation)
    _player.sequenceStateStream.listen((sequenceState) {
      final item = sequenceState.currentSource?.tag as MediaItem?;
      if (item != null) {
        // Don't overwrite live-radio metadata pushed via updateMediaItem
        if (_isLive && _currentItem != null && _currentItem!.id == item.id) {
          return;
        }
        // Preserve any duration we already resolved for this item
        final existingDuration =
            (_currentItem?.id == item.id) ? _currentItem?.duration : null;
        _currentItem = existingDuration != null
            ? item.copyWith(duration: existingDuration)
            : item;
        mediaItem.add(_currentItem!);
      }

      // Keep the queue populated so Android can navigate prev/next
      final sequence = sequenceState.sequence;
      if (sequence.isNotEmpty) {
        queue.add(sequence.map((s) => s.tag as MediaItem).toList());
      }
    });

    // ── Duration stream ────────────────────────────────────────────────────
    // When just_audio resolves the track duration (after buffering starts),
    // patch it into the current MediaItem so Android can draw the seek bar.
    _player.durationStream.listen((duration) {
      if (duration == null || _currentItem == null) return;
      _currentItem = _currentItem!.copyWith(duration: duration);
      mediaItem.add(_currentItem!);
      _broadcastState(); // Re-broadcast so updatePosition/duration are in sync
    });

    // Broadcast playback state on every player event
    _player.playbackEventStream.listen(_broadcastState);

    // Also update on explicit play/pause/stop transitions
    _player.playerStateStream.listen((_) => _broadcastState());
  }

  Duration _positionOffset = Duration.zero;
  bool _isLive = false;

  void setLivePlayback(bool isLive) {
    _isLive = isLive;
    if (!isLive) _positionOffset = Duration.zero;
    _broadcastState();
  }

  void syncLiveProgress(Duration elapsed) {
    if (_isLive) {
      _positionOffset = _player.position - elapsed;
      _broadcastState();
    }
  }

  void _broadcastState([PlaybackEvent? event]) {
    final playing = _player.playing;
    final queueIndex = event?.currentIndex ?? _player.currentIndex;
    final position =
        _isLive ? (_player.position - _positionOffset) : _player.position;

    // ── Notification controls ──────────────────────────────────────────────
    // Live radio  → [play/pause, stop]                  (no seek, no skip)
    // Podcast     → [⏮ prev?] [▶ play/pause] [⏭ next?]  (+ seekable progress)
    //   prev/next buttons only appear when there is actually a prev/next track.
    final List<MediaControl> controls;
    final List<int> compactIndices;

    if (_isLive) {
      controls = [
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
      ];
      compactIndices = const [0];
    } else {
      final hasPrev = _player.hasPrevious;
      final hasNext = _player.hasNext;

      controls = [
        if (hasPrev) MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        if (hasNext) MediaControl.skipToNext,
      ];

      // Build compact indices dynamically based on which buttons are present.
      // The play/pause button is always included; its index shifts with prev.
      final playIndex = hasPrev ? 1 : 0;
      compactIndices = [
        if (hasPrev) 0,           // prev  (only when available)
        playIndex,                 // play/pause
        if (hasNext) playIndex + 1, // next  (only when available)
      ];
    }

    playbackState.add(playbackState.value.copyWith(
      controls: controls,
      systemActions: {
        if (!_isLive) ...const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
      },
      androidCompactActionIndices: compactIndices,
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }

  // ── Playback controls ──────────────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) =>
      _player.seek(Duration.zero, index: index);

  /// Dynamically update the current MediaItem (used for live radio now-playing)
  @override
  Future<void> updateMediaItem(MediaItem item) async {
    _currentItem = item;
    mediaItem.add(item);
    _broadcastState();
  }
}
