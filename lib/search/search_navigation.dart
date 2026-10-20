import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../components/utils.dart';
import '../controller/live_tv_controller.dart';
import '../controller/podcast_controller.dart';
import '../controller/radio_controller.dart';
import '../controller/youtube_playlist_controller.dart';
import '../controller/youtube_playlist_item_controller.dart';
import '../models/livetvmodel/livetv_model.dart';
import '../models/presenter_model.dart';
import '../models/radiomodel/radio_model.dart';
import '../models/radiomodel/radio_podcast_model.dart';
import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';
import '../routes/routes.dart';
import 'search_models.dart';

/// Opens the screen for a search result. Sermons and episodes play in
/// place, so they aren't handled here.
abstract class SearchNavigation {
  static void open(SearchEntry entry) {
    final item = entry.payload;
    switch (entry.kind) {
      case SearchKind.presenter:
        Get.toNamed(Routes.getPresenterRoute(), arguments: entry.id);
      case SearchKind.series:
        Get.toNamed(Routes.getPresenterSeriesRoute(),
            arguments: item as (Presenter, SermonSeries));
      case SearchKind.podcast:
        Get.find<PodcastController>().setSelectedEpisode(item as RadioPodcast);
        Get.toNamed(Routes.getPodcastEpisodeListRoute());
      case SearchKind.playlist:
        final playlist = item as YoutubePlaylistModel;
        Get.find<YoutubePlaylistController>().setSelectedPlaylist(playlist);
        Get.toNamed(switch (playlist.channelName) {
          AppConstants.avventoKidsChannel =>
            Routes.getYoutubeKidsPlaylistItemRoute(),
          AppConstants.avventoMusicChannel =>
            Routes.getYoutubeMusicPlaylistItemRoute(),
          _ => Routes.getYoutubeMainPlaylistItemRoute(),
        });
      case SearchKind.video:
        Get.find<YoutubePlaylistItemController>()
            .setSelectedEpisode(item as YouTubePlaylistItemModel);
        Get.toNamed(Routes.getWatchYoutubeRoute());
      case SearchKind.live:
        if (entry.live == false) {
          // Not on air: the same notice as the live list.
          final context = Get.context;
          if (context != null) Utils.showComingSoonDialog(context);
        } else if (item is LiveTvModel) {
          Get.find<LiveTvController>().selectedTv(item);
          Get.toNamed(Routes.getLiveTvRoute());
        } else if (item is RadioModel) {
          Get.find<RadioController>().selectedRadio(item);
          Get.toNamed(Routes.getListenRoute());
        }
      case SearchKind.sermon || SearchKind.episode:
        break;
    }
  }
}
