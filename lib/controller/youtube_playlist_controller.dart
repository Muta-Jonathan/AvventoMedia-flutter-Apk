import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:get/get.dart';

class YoutubePlaylistController extends GetxController {
  Rx<YoutubePlaylistModel?> selectedPlaylist = Rx<YoutubePlaylistModel?>(null);

  void setSelectedPlaylist(YoutubePlaylistModel? playlist) {
    selectedPlaylist.value = playlist;
  }
}
