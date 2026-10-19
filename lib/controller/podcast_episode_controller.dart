import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:get/get.dart';

import 'audio_player_controller.dart';

class PodcastEpisodeController extends GetxController {
  Rx<PodcastEpisode?> selectedEpisode = Rx<PodcastEpisode?>(null);

  /// Episodes behind the current audio playlist.
  List<PodcastEpisode> _queue = [];

  void setSelectedEpisode(PodcastEpisode episode) {
    selectedEpisode.value = episode;
  }

  /// The show the queue came from, for "Continue listening".
  String queueShowTitle = '';

  void setQueue(List<PodcastEpisode> episodes, {String showTitle = ''}) {
    _queue = List.of(episodes);
    queueShowTitle = showTitle;
  }

  PodcastEpisode? queued(String id) =>
      _queue.firstWhereOrNull((e) => e.id == id);

  @override
  void onInit() {
    super.onInit();
    // Follow the player on next / previous / auto-advance.
    ever<MediaItem?>(Get.find<AudioPlayerController>().currentMediaItemRx,
        (item) {
      final episode = _queue.firstWhereOrNull((e) => e.id == item?.id);
      if (episode != null && episode.id != selectedEpisode.value?.id) {
        selectedEpisode.value = episode;
      }
    });
  }
}
