import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerController extends GetxController {
  late AudioPlayer audioPlayer;
  late AudioSource audioSource;
  MediaItem? currentMediaItem;

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
  }


  Future<void> setAudioSource(String url, MediaItem mediaItemTag) async {
    audioSource = AudioSource.uri(
      Uri.parse(url),
      tag: mediaItemTag,
    );

    currentMediaItem = mediaItemTag; // Set the current media item
    await audioPlayer.setAudioSource(audioSource);
  }

  Future<void> play() async {
    await audioPlayer.play();
  }

  Future<void> pause() async {
    await audioPlayer.pause();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
