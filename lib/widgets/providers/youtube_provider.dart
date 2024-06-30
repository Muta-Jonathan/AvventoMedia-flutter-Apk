import 'package:avvento_media/apis/youtube_api.dart';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:flutter/material.dart';

class YoutubeProvider extends ChangeNotifier {
  List<YoutubePlaylistModel> _youtubeMusicPlaylists = [];
  List<YoutubePlaylistModel> _youtubeKidsPlaylists = [];
  List<YouTubePlaylistItemModel> _youtubeMusicPlaylistItems = [];
  List<YouTubePlaylistItemModel> _youtubeKidsPlaylistItems = [];
  bool _isLoadingItems = false;

  // avventomusic
  List<YoutubePlaylistModel> get youtubeMusicPlaylists => _youtubeMusicPlaylists;
  List<YouTubePlaylistItemModel> get youtubeMusicPlaylistItems => _youtubeMusicPlaylistItems;

// avventokids
  List<YoutubePlaylistModel> get youtubeKidsPlaylists => _youtubeKidsPlaylists;
  List<YouTubePlaylistItemModel> get youtubeKidsPlaylistItems => _youtubeKidsPlaylistItems;
  bool get isLoading => _isLoadingItems;


  Future<void> fetchAllMusicPlaylists() async {
    try {
      _youtubeMusicPlaylists = await YouTubeApiService().fetchPlaylists(
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
      _youtubeMusicPlaylistItems = await YouTubeApiService().fetchPlaylistItems(
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

  Future<void> fetchAllKidsPlaylists() async {
    try {
      _youtubeKidsPlaylists = await YouTubeApiService().fetchPlaylists(
          apiKey: AppConstants.avventoKidsYoutubeApiKey,
          channelId: AppConstants.avventoKidsYoutubeChannelID);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> fetchAllKidsPlaylistItem({playlistId}) async {
    _isLoadingItems = true;
    notifyListeners();

    try {
      _youtubeKidsPlaylistItems = await YouTubeApiService().fetchPlaylistItems(
          apiKey: AppConstants.avventoKidsYoutubeApiKey,
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
