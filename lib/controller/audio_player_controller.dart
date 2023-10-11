import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerController extends GetxController {
  late AudioPlayer audioPlayer;

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
  }

  Future<void> setAudioUrl(String url) async {
    await audioPlayer.setUrl(url);
  }

  void play() {
    audioPlayer.play();
  }

  void pause() {
    audioPlayer.pause();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
