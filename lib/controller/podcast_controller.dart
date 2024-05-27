import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:get/get.dart';

class PodcastController extends GetxController {
  Rx<RadioPodcast?> selectedEpisode = Rx<RadioPodcast?>(null);

  void setSelectedEpisode(RadioPodcast episode) {
    selectedEpisode.value = episode;
  }
}
