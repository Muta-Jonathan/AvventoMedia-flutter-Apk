import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:get/get.dart';

class PodcastEpisodeController extends GetxController {
  Rx<PodcastEpisode?> selectedEpisode = Rx<PodcastEpisode?>(null);

  void setSelectedEpisode(PodcastEpisode episode) {
    selectedEpisode.value = episode;
  }
}
