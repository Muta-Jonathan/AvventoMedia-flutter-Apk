import 'package:avvento_media/apis/youtube_api.dart';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:flutter/material.dart';

import '../../apis/firestore_service_api.dart';

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
    final String musicApiKey = await FirestoreServiceAPI().fetchApiKey('avventoMusicApi');
    try {
      _youtubeMusicPlaylists = await YouTubeApiService().fetchPlaylists(
          apiKey: musicApiKey,
          channelId: AppConstants.avventomusicYoutubeChannelID);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> fetchAllMusicPlaylistItem({playlistId}) async {
    final String musicApiKey = await FirestoreServiceAPI().fetchApiKey('avventoMusicApi');
    _isLoadingItems = true;
    notifyListeners();

    try {
      _youtubeMusicPlaylistItems = await YouTubeApiService().fetchPlaylistItems(
          apiKey: musicApiKey,
          playlistId: playlistId);
      notifyListeners();
    } catch (error) {
      // Handle error
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllKidsPlaylists() async {
    final String kidsApiKey = await FirestoreServiceAPI().fetchApiKey('avventoKidsApi');
    try {
      _youtubeKidsPlaylists = await YouTubeApiService().fetchPlaylists(
          apiKey: kidsApiKey,
          channelId: AppConstants.avventoKidsYoutubeChannelID);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> fetchAllKidsPlaylistItem({playlistId}) async {
    final String kidsApiKey = await FirestoreServiceAPI().fetchApiKey('avventoKidsApi');
    _isLoadingItems = true;
    notifyListeners();

    try {
      _youtubeKidsPlaylistItems = await YouTubeApiService().fetchPlaylistItems(
          apiKey: kidsApiKey,
          playlistId: playlistId);
      notifyListeners();
    } catch (error) {
      // Handle error
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

}
