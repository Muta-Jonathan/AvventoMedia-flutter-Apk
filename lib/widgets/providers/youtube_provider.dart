import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:flutter/material.dart';

import '../../apis/firestore_service_api.dart';

class YoutubeProvider extends ChangeNotifier {
  // --- Playlists ---
  List<YoutubePlaylistModel> _youtubeMusicPlaylists = [];
  List<YoutubePlaylistModel> _youtubeKidsPlaylists = [];
  List<YoutubePlaylistModel> _youtubeMainPlaylists = [];

  // --- Playlist Items ---
  List<YouTubePlaylistItemModel> _youtubeMusicPlaylistItems = [];
  List<YouTubePlaylistItemModel> _youtubeKidsPlaylistItems = [];
  List<YouTubePlaylistItemModel> _youtubeMainPlaylistItems = [];

  // --- Loading indicator ---
  bool _isLoadingItems = false;
  bool get isLoading => _isLoadingItems;

  // --- Getters ---
  List<YoutubePlaylistModel> get youtubeMusicPlaylists => _youtubeMusicPlaylists;
  List<YoutubePlaylistModel> get youtubeKidsPlaylists => _youtubeKidsPlaylists;
  List<YoutubePlaylistModel> get youtubeMainPlaylists => _youtubeMainPlaylists;

  List<YouTubePlaylistItemModel> get youtubeMusicPlaylistItems => _youtubeMusicPlaylistItems;
  List<YouTubePlaylistItemModel> get youtubeKidsPlaylistItems => _youtubeKidsPlaylistItems;
  List<YouTubePlaylistItemModel> get youtubeMainPlaylistItems => _youtubeMainPlaylistItems;

  // Firestore API instance
  final _firestoreAPI = FirestoreServiceAPI.instance;

  /// -------------------------
  /// STREAM PLAYLISTS (REAL-TIME)
  /// -------------------------
  void streamMusicPlaylists() {
    _isLoadingItems = true;
    notifyListeners();

    _firestoreAPI.streamPlaylists(AppConstants.avventoMusicChannel).listen((playlists) {
      _youtubeMusicPlaylists = playlists;
      notifyListeners();
    });
  }

  void streamKidsPlaylists() {
    _isLoadingItems = true;
    notifyListeners();

    _firestoreAPI.streamPlaylists(AppConstants.avventoKidsChannel).listen((playlists) {
      _youtubeKidsPlaylists = playlists;
      notifyListeners();
    });
  }

  void streamMainPlaylists() {
    _isLoadingItems = true;
    notifyListeners();

    _firestoreAPI.streamPlaylists(AppConstants.avventoMainChannel).listen((playlists) {
      _youtubeMainPlaylists = playlists;
      notifyListeners();
    });
  }

  /// -------------------------
  /// STREAM PLAYLIST ITEMS (REAL-TIME)
  /// -------------------------
  void streamMusicPlaylistItems({playlistId}) {
    _isLoadingItems = true;
    notifyListeners();

    _firestoreAPI.streamPlaylistItems(AppConstants.avventoMusicChannel, playlistId).listen((items) {
      _youtubeMusicPlaylistItems = items;
      _isLoadingItems = false;
      notifyListeners();
    },
      onError: (error) {},
    );
  }

  void streamKidsPlaylistItems({playlistId}) {
    _isLoadingItems = true;
    notifyListeners();

    _firestoreAPI.streamPlaylistItems(AppConstants.avventoKidsChannel, playlistId).listen((items) {
      _youtubeKidsPlaylistItems = items;
      _isLoadingItems = false;
      notifyListeners();
    });
  }

  void streamMainPlaylistItems({playlistId}) {
    _isLoadingItems = true;
    notifyListeners();

    _firestoreAPI.streamPlaylistItems(AppConstants.avventoMainChannel, playlistId).listen((items) {
      _youtubeMainPlaylistItems = items;
      _isLoadingItems = false;
      notifyListeners();
    });
  }

  /// -------------------------
  /// FETCH SINGLE PLAYLIST OR VIDEO
  /// -------------------------
  Future<Map<String, dynamic>?> fetchMainPlaylistById(String playlistId) async {
    return _firestoreAPI.fetchPlaylistById(AppConstants.avventoMainChannel, playlistId);
  }

  Future<Map<String, dynamic>?> fetchVideoById(String playlistId, String videoId) async {
    return _firestoreAPI.fetchVideoById(AppConstants.avventoMainChannel, playlistId, videoId);
  }
}
