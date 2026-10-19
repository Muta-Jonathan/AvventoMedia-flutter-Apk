import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/utils.dart';
import '../models/radiomodel/radio_station_model.dart';
import '../widgets/audio_players/player_panel.dart';
import 'settings_controller.dart';
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
    runOutsideBuild(() {
      final next = _currentMediaItem;
      final shown = currentMediaItemRx.value;
      // MediaItem == only compares ids, so Rx would keep the old item when
      // live radio changes the song. Clear it first to store the new one.
      if (next != null && shown == next && !_sameContent(shown!, next)) {
        currentMediaItemRx.value = null;
      }
      currentMediaItemRx.value = next;
    });
  }

  static bool _sameContent(MediaItem a, MediaItem b) =>
      a.title == b.title &&
      a.artist == b.artist &&
      a.album == b.album &&
      a.artUri == b.artUri &&
      a.duration == b.duration;

  final RxBool hasNext = false.obs;
  final RxBool hasPrevious = false.obs;
  List<double> speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  int currentSpeedIndex = 1;

  /// Playback speed, for the player's speed pill.
  final RxDouble speed = 1.0.obs;

  /// Shuffle within the current episode queue.
  final RxBool shuffleOn = false.obs;

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
    if (Get.isRegistered<SettingsController>()) {
      ever(Get.find<SettingsController>().miniPlayerEnabled, (bool enabled) {
        if (!isPlayerActive.value) return;
        if (enabled) {
          isMiniPlayerVisible.value = true;
        } else if (panelPercentage.value <= 0.01) {
          isMiniPlayerVisible.value = false;
        }
      });
    }
    audioPlayer.setLoopMode(LoopMode.off);

    _handlerReady =
        _startAudioService ? _initAudioService() : Future.value(null);
    
    // Listen to sequence state changes to dynamically update current item and next/prev availability
    audioPlayer.sequenceStateStream.listen((sequenceState) {
      final currentItem = sequenceState.currentSource?.tag as MediaItem?;
      // Keep live now-playing metadata; the stream's tag still holds the
      // song that was on when it started.
      if (currentItem != null &&
          !(isLive.value && currentItem.id == currentMediaItem?.id)) {
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

  /// Pushes the station's now-playing song to the mini player, full player
  /// and notification while the radio is loaded, from any screen.
  void syncRadioStation(RadioStation station) {
    if (!isLive.value || !isPlayerActive.value || currentMediaItem == null) {
      return;
    }
    final item = currentMediaItem!;
    if (item.title == station.nowPlayingTitle &&
        item.artist == station.artist &&
        item.artUri.toString() == station.imageUrl) {
      return; // Only the elapsed time moved.
    }
    updateRadioProgram(
      station.nowPlayingTitle,
      station.artist,
      station.imageUrl,
      Utils.parseDuration(station.duration),
      Utils.parseDuration(station.elapsed),
    );
  }

  Future<void> setAudioSource(String url, MediaItem mediaItemTag) async {
    audioSource = AudioSource.uri(
      Uri.parse(url),
      tag: mediaItemTag,
    );

    currentMediaItem = mediaItemTag;
    playlist = null;

    isPlayerActive.value = true;
    _revealPlayer();

    // Tell the handler this is live (no seek bar, no skip buttons)
    final handler = await _handlerReady;
    if (handler is MyAudioHandler) {
      handler.setLivePlayback(isLive.value);
    }

    if (!await _load(audioSource!)) return;
    await handler?.updateMediaItem(mediaItemTag);
  }

  /// [initialPosition] resumes the first track part-way.
  Future<void> setAudioPlaylist(List<AudioSource> sources, int initialIndex,
      {Duration? initialPosition}) async {
    // A new queue plays in the order it was built (e.g. as a feed shows it).
    if (shuffleOn.value) {
      shuffleOn.value = false;
      await audioPlayer.setShuffleModeEnabled(false);
    }
    playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: sources,
    );

    if (sources.isNotEmpty && initialIndex >= 0 && initialIndex < sources.length) {
      currentMediaItem =
          (sources[initialIndex] as IndexedAudioSource).tag as MediaItem?;
    }

    isPlayerActive.value = true;
    _revealPlayer();

    // Tell the handler this is a seekable playlist (show progress bar + skip)
    final handler = await _handlerReady;
    if (handler is MyAudioHandler) {
      handler.setLivePlayback(false);
    }

    await _load(playlist!,
        initialIndex: initialIndex, initialPosition: initialPosition);
  }

  /// Loads [source]; false if a stop / close / newer load interrupted it.
  /// just_audio throws PlayerInterruptedException for that, which callers
  /// are expected to catch.
  Future<bool> _load(AudioSource source,
      {int? initialIndex, Duration? initialPosition}) async {
    try {
      await audioPlayer.setAudioSource(
        source,
        initialIndex: initialIndex,
        initialPosition: initialIndex == null
            ? null
            : (initialPosition ?? Duration.zero),
      );
      return true;
    } on PlayerInterruptedException {
      return false;
    }
  }

  Future<void> setSpeed(double value) async {
    speed.value = value;
    currentSpeedIndex = speeds.indexOf(value);
    await audioPlayer.setSpeed(value);
  }

  Future<void> toggleShuffle() async {
    final on = !shuffleOn.value;
    shuffleOn.value = on;
    if (on) await audioPlayer.shuffle();
    await audioPlayer.setShuffleModeEnabled(on);
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
    final wasOpen = panelPercentage.value > 0.01;
    panelPercentage.value = percentage;
    if (percentage >= 0.99) {
      _addExpandedBackEntry();
    } else if (percentage <= 0.01) {
      _removeExpandedBackEntry();
      // Mini bar disabled: collapsing closes the player (audio continues).
      if (wasOpen && !_miniBarAllowed) isMiniPlayerVisible.value = false;
    }
  }

  /// "Allow Mini Player" in More; on when there are no settings (tests).
  bool get _miniBarAllowed =>
      !Get.isRegistered<SettingsController>() ||
      Get.find<SettingsController>().miniPlayerEnabled.value;

  /// Shows the player for new playback: the mini bar, or the full player
  /// when the mini bar is disabled.
  void _revealPlayer() {
    isMiniPlayerVisible.value = true;
    if (!_miniBarAllowed) panelController.expand();
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
    if (!_miniBarAllowed) return;
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
