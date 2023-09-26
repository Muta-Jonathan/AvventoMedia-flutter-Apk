import 'package:get/get.dart';
import '../models/spreakermodels/spreaker_episodes.dart';

class EpisodeController extends GetxController {
  Rx<SpreakerEpisode?> selectedEpisode = Rx<SpreakerEpisode?>(null);

  void setSelectedEpisode(SpreakerEpisode episode) {
    selectedEpisode.value = episode;
  }
}
