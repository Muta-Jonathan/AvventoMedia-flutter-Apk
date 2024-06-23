import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:get/get.dart';

class YoutubePlaylistItemController extends GetxController {
  Rx<YouTubePlaylistItemModel?> selectedPlaylistItem = Rx<YouTubePlaylistItemModel?>(null);

  void setSelectedEpisode(YouTubePlaylistItemModel item) {
    selectedPlaylistItem.value = item;
  }
}
