import 'package:avvento_media/controller/live_tv_controller.dart';
import 'package:get/get.dart';

import '../controller/audio_player_controller.dart';
import '../controller/connectivity_controller.dart';
import '../controller/download_controller.dart';
import '../controller/episode_controller.dart';
import '../controller/episode_progress_controller.dart';
import '../controller/library_controller.dart';
import '../controller/podcast_controller.dart';
import '../controller/podcast_episode_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AudioPlayerController());
    Get.put(LiveTvController());
    Get.put(EpisodeController());
    Get.put(PodcastEpisodeController());
    Get.put(PodcastController());
    Get.put(LibraryController());
    Get.put(EpisodeProgressController());
    Get.put(DownloadController());
    Get.put(ConnectivityController());
  }
}
