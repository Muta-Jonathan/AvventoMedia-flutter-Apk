import 'package:get/get.dart';

import '../controller/audio_player_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AudioPlayerController());
  }
}
