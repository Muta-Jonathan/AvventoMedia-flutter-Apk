import 'package:avvento_media/apis/youtube_api.dart';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:flutter/material.dart';

class YoutubeProvider extends ChangeNotifier {
  List<YoutubePlaylistModel> _youtubePlaylists = [];
  List<YouTubePlaylistItemModel> _youtubePlaylistItems = [];
  bool _isLoadingItems = false;

  List<YoutubePlaylistModel> get youtubePlaylists => _youtubePlaylists;
  List<YouTubePlaylistItemModel> get youtubePlaylistItems => _youtubePlaylistItems;
  bool get isLoading => _isLoadingItems;


  Future<void> fetchAllMusicPlaylists() async {
    try {
      _youtubePlaylists = await YouTubeApiService().fetchPlaylists(
          apiKey: AppConstants.avventomusicYoutubeApiKey,
          channelId: AppConstants.avventomusicYoutubeChannelID);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> fetchAllMusicPlaylistItem({playlistId}) async {
    _isLoadingItems = true;
    notifyListeners();

    try {
      _youtubePlaylistItems = await YouTubeApiService().fetchPlaylistItems(
          apiKey: AppConstants.avventomusicYoutubeApiKey,
          playlistId: playlistId);
      notifyListeners();
    } catch (error) {
      // Handle error
    }finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

}
