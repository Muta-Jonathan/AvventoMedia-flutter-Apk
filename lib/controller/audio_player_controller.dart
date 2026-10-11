import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/audio_players/player_panel.dart';
import '../main.dart';
import 'audio_handler.dart';

class AudioPlayerController extends GetxController {
  /// [player] and [startAudioService] exist for tests.
  AudioPlayerController({AudioPlayer? player, bool startAudioService = true})
      : audioPlayer = player ?? AudioPlayer(),
        _startAudioService = startAudioService;

  final AudioPlayer audioPlayer;
  final bool _startAudioService;

  /// Completes once AudioService is ready (null when not started, in tests).
  /// Await it before using the handler: playback can start before init ends.
  late final Future<AudioHandler?> _handlerReady;
  AudioSource? audioSource;
  ConcatenatingAudioSource? playlist;

  MediaItem? _currentMediaItem;

  /// Reactive copy of [currentMediaItem] for use in Obx.
  final Rxn<MediaItem> currentMediaItemRx = Rxn<MediaItem>();

  MediaItem? get currentMediaItem => _currentMediaItem;
  set currentMediaItem(MediaItem? item) {
    _currentMediaItem = item;
    runOutsideBuild(() => currentMediaItemRx.value = _currentMediaItem);
  }

  final RxBool hasNext = false.obs;
  final RxBool hasPrevious = false.obs;
  List<double> speeds = [1.0, 1.25, 1.5, 1.75, 2.0];
  int currentSpeedIndex = 0;

  /// Whether the current audio source is live radio (true) or podcast (false)
  final RxBool isLive = false.obs;

  /// Controls mini player visibility — user can hide on current page
  final RxBool isMiniPlayerVisible = true.obs;

  /// Tracks whether the player has an active media source
  final RxBool isPlayerActive = false.obs;

  /// Controls the expand/collapse state of the sliding mini player panel
  final PlayerPanelController panelController = PlayerPanelController();

  /// 0.0 = fully collapsed (mini bar), 1.0 = fully expanded (full player)
  final RxDouble panelPercentage = 0.0.obs;

  /// Tracks the currently active route name so the player overlay knows
  /// whether the BottomNavigationBar is visible (home route only).
  final RxString currentRoute = '/'.obs;

  /// Lets the back button collapse the expanded player.
  LocalHistoryEntry? _expandedBackEntry;

  /// Navigator inside the full player, so its sheets have a Navigator.
  NavigatorState? fullPlayerNavigator;

  @override
  void onInit() {
    super.onInit();
    audioPlayer.setLoopMode(LoopMode.off);

    _handlerReady =
        _startAudioService ? _initAudioService() : Future.value(null);
    
    // Listen to sequence state changes to dynamically update current item and next/prev availability
    audioPlayer.sequenceStateStream.listen((sequenceState) {
      final currentItem = sequenceState.currentSource?.tag as MediaItem?;
      if (currentItem != null) {
        currentMediaItem = currentItem;
      }
      
      hasNext.value = audioPlayer.hasNext;
      hasPrevious.value = audioPlayer.hasPrevious;
    });
  }

  Future<AudioHandler> _initAudioService() async {
    // Request notification permission for Android 13+ before initializing the audio service
    await Permission.notification.request();

    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(audioPlayer),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'tv.avventomedia.app.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationIcon: 'mipmap/ic_logo_icon',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    return audioHandler;
  }

  Future<void> updateRadioProgram(String newTitle, String newArtist, String newImageUrl, Duration duration, Duration elapsed) async {
    final handler = await _handlerReady;
    if (handler is MyAudioHandler) {
      handler.setLivePlayback(isLive.value);
      handler.syncLiveProgress(elapsed);
    }

    if (currentMediaItem != null) {
      final updatedItem = currentMediaItem!.copyWith(
        title: newTitle,
        artist: newArtist,
        artUri: Uri.parse(newImageUrl),
        duration: duration,
      );
      currentMediaItem = updatedItem;
      await handler?.updateMediaItem(updatedItem);
    }
  }

  Future<void> setAudioSource(String url, MediaItem mediaItemTag) async {
    audioSource = AudioSource.uri(
      Uri.parse(url),
      tag: mediaItemTag,
    );

    currentMediaItem = mediaItemTag;
    playlist = null;

    isPlayerActive.value = true;
    isMiniPlayerVisible.value = true;

    // Tell the handler this is live (no seek bar, no skip buttons)
    final handler = await _handlerReady;
    if (handler is MyAudioHandler) {
      handler.setLivePlayback(isLive.value);
    }

    if (!await _load(audioSource!)) return;
    await handler?.updateMediaItem(mediaItemTag);
  }

  Future<void> setAudioPlaylist(List<AudioSource> sources, int initialIndex) async {
    playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: sources,
    );

    if (sources.isNotEmpty && initialIndex >= 0 && initialIndex < sources.length) {
      currentMediaItem =
          (sources[initialIndex] as IndexedAudioSource).tag as MediaItem?;
    }

    isPlayerActive.value = true;
    isMiniPlayerVisible.value = true;

    // Tell the handler this is a seekable playlist (show progress bar + skip)
    final handler = await _handlerReady;
    if (handler is MyAudioHandler) {
      handler.setLivePlayback(false);
    }

    await _load(playlist!, initialIndex: initialIndex);
  }

  /// Loads [source]; false if a stop / close / newer load interrupted it.
  /// just_audio throws PlayerInterruptedException for that, which callers
  /// are expected to catch.
  Future<bool> _load(AudioSource source, {int? initialIndex}) async {
    try {
      await audioPlayer.setAudioSource(
        source,
        initialIndex: initialIndex,
        initialPosition: initialIndex == null ? null : Duration.zero,
      );
      return true;
    } on PlayerInterruptedException {
      return false;
    }
  }

  Future<void> playNext() async {
    if (audioPlayer.hasNext) {
      await audioPlayer.seekToNext();
    }
  }

  Future<void> playPrevious() async {
    if (audioPlayer.hasPrevious) {
      await audioPlayer.seekToPrevious();
    }
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (playlist != null) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      await playlist!.move(oldIndex, newIndex);
    }
  }

  Future<void> play() async {
    if (isLive.value && audioPlayer.processingState == ProcessingState.idle && audioSource != null) {
      if (!await _load(audioSource!)) return;
    }
    await audioPlayer.play();
  }

  Future<void> pause() async {
    if (isLive.value) {
      await audioPlayer.stop();
    } else {
      await audioPlayer.pause();
    }
  }

  /// Restart the current track after it completes.
  Future<void> replay() async {
    await audioPlayer.seek(Duration.zero);
    await audioPlayer.play();
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }

  void onPanelPercentageChanged(double percentage) {
    panelPercentage.value = percentage;
    if (percentage >= 0.99) {
      _addExpandedBackEntry();
    } else if (percentage <= 0.01) {
      _removeExpandedBackEntry();
    }
  }

  void collapsePlayer() {
    panelController.collapse();
  }

  void _addExpandedBackEntry() {
    if (_expandedBackEntry != null) return;
    final route = Get.routing.route;
    if (route is! LocalHistoryRoute) return;

    late final LocalHistoryEntry entry;
    entry = LocalHistoryEntry(
      impliesAppBarDismissal: false,
      onRemove: () {
        // Skip when removed by _removeExpandedBackEntry.
        if (!identical(_expandedBackEntry, entry)) return;
        _expandedBackEntry = null;
        // Close an open sheet (e.g. speed) before collapsing the player.
        final playerNavigator = fullPlayerNavigator;
        if (playerNavigator != null &&
            playerNavigator.mounted &&
            playerNavigator.canPop()) {
          playerNavigator.pop();
          _addExpandedBackEntry();
        } else {
          collapsePlayer();
        }
      },
    );
    _expandedBackEntry = entry;
    route.addLocalHistoryEntry(entry);
  }

  void _removeExpandedBackEntry() {
    final entry = _expandedBackEntry;
    if (entry == null) return;
    _expandedBackEntry = null;
    entry.remove();
  }

  void setCurrentRoute(String route) =>
      runOutsideBuild(() => currentRoute.value = route);

  /// Stop audio and completely hide the mini player globally
  Future<void> closeMiniPlayer() async {
    // The panel is removed, so it won't report its percentage again.
    onPanelPercentageChanged(0);
    isPlayerActive.value = false;
    await audioPlayer.stop();
  }

  /// Hide mini player on the current page
  void hideMiniPlayer() => isMiniPlayerVisible.value = false;

  /// Show mini player (called on page navigation)
  void showMiniPlayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isMiniPlayerVisible.value = true;
    });
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}

/// Defers [update] past the current build to avoid markNeedsBuild errors.
/// A microtask is used because the scheduler phase can't detect every build
/// (e.g. the first one from attachRootWidget runs while idle).
void runOutsideBuild(VoidCallback update) => scheduleMicrotask(update);
