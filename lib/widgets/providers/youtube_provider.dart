import 'package:avvento_media/apis/youtube_api.dart';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../apis/firestore_service_api.dart';

class YoutubeProvider extends ChangeNotifier {
  List<YoutubePlaylistModel> _youtubeMusicPlaylists = [];
  List<YoutubePlaylistModel> _youtubeKidsPlaylists = [];
  List<YouTubePlaylistItemModel> _youtubeMusicPlaylistItems = [];
  List<YouTubePlaylistItemModel> _youtubeKidsPlaylistItems = [];
  bool _isLoadingItems = false;
  final String? musicApiKey = dotenv.env["AVVENTOMUSIC_APIKEY"];
  final String? musicYoutubeChannelID = dotenv.env["AVVENTOMUSIC_YT_CHANNEL_ID"];
  final String? kidsApiKey = dotenv.env["AVVENTOKIDS_APIKEY"];
  final String? kidsYoutubeChannelID = dotenv.env["AVVENTOKIDS_YT_CHANNEL_ID"];

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
          apiKey: musicApiKey,
          channelId: musicYoutubeChannelID);
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
    try {
      _youtubeKidsPlaylists = await YouTubeApiService().fetchPlaylists(
          apiKey: kidsApiKey,
          channelId: kidsYoutubeChannelID);
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
