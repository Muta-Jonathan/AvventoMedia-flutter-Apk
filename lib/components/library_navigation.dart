import 'package:get/get.dart';

import '../controller/podcast_controller.dart';
import '../controller/podcast_episode_controller.dart';
import '../controller/youtube_playlist_controller.dart';
import '../controller/youtube_playlist_item_controller.dart';
import '../models/radiomodel/podcast_episode_model.dart';
import '../models/radiomodel/radio_podcast_model.dart';
import '../models/saved_item_model.dart';
import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';
import '../routes/routes.dart';

class LibraryNavigation {
  static void navigateToSavedItem(SavedItem item) {
    if (item.type == 'video') {
      final model = YouTubePlaylistItemModel(
        id: item.videoId ?? item.id,
        videoId: item.videoId ?? item.id,
        title: item.title,
        description: item.description ?? '',
        thumbnailUrl: item.thumbnailUrl,
        channelTitle: item.groupTitle,
        duration: item.duration ?? '',
        views: item.views ?? '',
        publishedAt: item.publishedAtItem != null ? DateTime.parse(item.publishedAtItem!) : DateTime.now(),
      );
      Get.find<YoutubePlaylistItemController>().setSelectedEpisode(model);
      Get.toNamed(Routes.getWatchYoutubeRoute());
    } else if (item.type == 'playlist') {
      final model = YoutubePlaylistModel(
        id: item.id,
        title: item.title,
        description: item.description ?? '',
        thumbnailUrl: item.thumbnailUrl,
        itemCount: 0,
        publishedAt: item.publishedAtItem != null ? DateTime.parse(item.publishedAtItem!) : DateTime.now(),
      );
      Get.find<YoutubePlaylistController>().setSelectedPlaylist(model);
      // For playlist we route to Main playlist item page for now
      Get.toNamed(Routes.getYoutubeMainPlaylistItemRoute());
    } else if (item.type == 'podcast_episode') {
      final model = PodcastEpisode(
        id: item.id,
        title: item.title,
        description: item.description ?? '',
        playlistMediaArtist: item.groupTitle,
        playlistMediaAlbum: item.groupTitle,
        publishedAt: item.publishedAtItem != null ? (DateTime.parse(item.publishedAtItem!).millisecondsSinceEpoch ~/ 1000) : 0,
        downloadLink: item.url ?? '',
        publicLink: '',
        isPublished: true,
        art: item.thumbnailUrl,
        media: item.url ?? '',
      );
      Get.find<PodcastEpisodeController>().setSelectedEpisode(model);
      Get.toNamed(Routes.getPodcastRoute());
    } else if (item.type == 'podcast_show') {
      final model = RadioPodcast(
        id: item.id,
        title: item.title,
        description: item.description ?? '',
        author: item.groupTitle,
        email: '',
        art: item.thumbnailUrl,
        isPublished: true,
        episodes: 0,
        categories: [],
        episodesLink: '',
        lastUpdated: item.publishedAtItem != null ? DateTime.parse(item.publishedAtItem!) : DateTime.now(),
      );
      Get.find<PodcastController>().setSelectedEpisode(model);
      Get.toNamed(Routes.getPodcastEpisodeListRoute());
    }
  }
}
