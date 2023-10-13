import 'package:avvento_radio/controller/live_tv_controller.dart';
import 'package:get/get.dart';

import '../controller/audio_player_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AudioPlayerController());
    Get.put(LiveTvController());
  }
}
