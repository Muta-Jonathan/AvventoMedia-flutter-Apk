import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerController extends GetxController {
  late AudioPlayer audioPlayer;
  AudioSource? audioSource;
  ConcatenatingAudioSource? playlist;
  MediaItem? currentMediaItem;
  
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

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
    audioPlayer.setLoopMode(LoopMode.off);
    
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

  Future<void> setAudioSource(String url, MediaItem mediaItemTag) async {
    audioSource = AudioSource.uri(
      Uri.parse(url),
      tag: mediaItemTag,
    );

    currentMediaItem = mediaItemTag;
    playlist = null; // Clear playlist when playing single source

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isPlayerActive.value = true;
    });
    await audioPlayer.setAudioSource(audioSource!);
  }

  Future<void> setAudioPlaylist(List<AudioSource> sources, int initialIndex) async {
    playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: sources,
    );
    
    if (sources.isNotEmpty && initialIndex >= 0 && initialIndex < sources.length) {
       currentMediaItem = (sources[initialIndex] as IndexedAudioSource).tag as MediaItem?;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isPlayerActive.value = true;
    });
    
    await audioPlayer.setAudioSource(playlist!, initialIndex: initialIndex, initialPosition: Duration.zero);
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
    await audioPlayer.play();
  }

  Future<void> pause() async {
    await audioPlayer.pause();
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }

  /// Stop audio and completely hide the mini player globally
  Future<void> closeMiniPlayer() async {
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
