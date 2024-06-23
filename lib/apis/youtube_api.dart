import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';

class YouTubeApiService {
  Future<List<YoutubePlaylistModel>> fetchPlaylists({apiKey,channelId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? avventoMusicCachedData = prefs.getString('avvento_music_cache');

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      final data = json.decode(avventoMusicCachedData!);

      return List<YoutubePlaylistModel>.from(data['items'].map((data) => YoutubePlaylistModel.fromJson(data)));
    } else {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/playlists?part=snippet,contentDetails&channelId=$channelId&maxResults=25&key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cache the fetched data in SharedPreferences.
        prefs.setString('avvento_music_cache', response.body);

        final List<dynamic> items = data['items'];
        return items.map((json) => YoutubePlaylistModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load playlists');
      }
    }
  }

  Future<List<YouTubePlaylistItemModel>> fetchPlaylistItems({apiKey,playlistId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? avventoMusicItemCachedData = prefs.getString('avvento_music_item_cache');

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      final data = json.decode(avventoMusicItemCachedData!);

      return List<YouTubePlaylistItemModel>.from(data['items'].map((data) => YouTubePlaylistItemModel.fromJson(data)));
    } else {}
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$playlistId&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      List<YouTubePlaylistItemModel> items = (json['items'] as List).map((item) {
        return YouTubePlaylistItemModel.fromJson(item);
      }).toList();

      // Fetch video details including duration
      items = await _fetchVideoDetails(items, apiKey);

      // Cache the fetched data in SharedPreferences.
      prefs.setString('avvento_music_item_cache', response.body);


      return items;
    } else {
      throw Exception('Failed to load playlist items');
    }
  }

  Future<List<YouTubePlaylistItemModel>> _fetchVideoDetails(List<YouTubePlaylistItemModel> items, apiKey) async {
    final videoIds = items.map((item) => item.videoId).join(',');
    final url = 'https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=$videoIds&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videoDetailsMap = {for (var item in data['items']) item['id']: item};

      items = items.map((item) {
        final videoDetails = videoDetailsMap[item.videoId];
        final duration = videoDetails['contentDetails']['duration'];
        final formattedDuration = _formatDuration(duration);
        return item.copyWith(duration: formattedDuration);
      }).toList();

      return items;
    } else {
      throw Exception('Failed to load video details');
    }
  }

  String _formatDuration(String duration) {
    // Duration format from YouTube API is in ISO 8601 (e.g., PT1H3M52S)
    String formattedDuration = '';

    // Remove the 'PT' prefix and 'S' suffix
    duration = duration.replaceAll('PT', '').replaceAll('S', '');

    // Split the duration into components (hours, minutes, seconds)
    List<String> components = duration.split(RegExp(r'[H,M]'));

    int hours = 0, minutes = 0, seconds = 0;

    // Parse hours, minutes, and seconds from components
    if (components.isNotEmpty) {
      if (components.length == 3) {
        hours = int.parse(components[0]);
        minutes = int.parse(components[1]);
        seconds = int.parse(components[2]);
      } else if (components.length == 2) {
        minutes = int.parse(components[0]);
        seconds = int.parse(components[1]);
      } else if (components.length == 1) {
        seconds = int.parse(components[0]);
      }
    }

    // Format the duration based on hours, minutes, and seconds
    if (hours > 0) {
      formattedDuration = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      formattedDuration = '$minutes:${seconds.toString().padLeft(2, '0')}';
    }

    return formattedDuration;
  }


}
