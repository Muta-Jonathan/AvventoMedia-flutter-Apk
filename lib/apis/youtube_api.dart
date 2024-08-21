import 'dart:convert';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';

class YouTubeApiService {
  Future<List<YoutubePlaylistModel>> fetchPlaylists({apiKey,channelId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'avvento_$channelId';
    final String? avventoMusicCachedData = prefs.getString(cacheKey);

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      if (avventoMusicCachedData != null) {
        final data = json.decode(avventoMusicCachedData);
        final List<YoutubePlaylistModel> cachedPlaylists = List<YoutubePlaylistModel>.from(
            data['items'].map((data) => YoutubePlaylistModel.fromJson(data))
        );

        // Filter playlists with non-zero item counts
        final filteredPlaylists = cachedPlaylists.where((item) => item.itemCount != 0).toList();
        // Sort filtered playlists by publishedAt date
        filteredPlaylists.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

        return filteredPlaylists;
      } else {
        throw Exception('No cached data available');
      }
    } else {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.youtubePlaylistAPI}?part=snippet,contentDetails&channelId=$channelId&maxResults=25&key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> items = data['items'];
        final List<YoutubePlaylistModel> playlists = items.map((json) => YoutubePlaylistModel.fromJson(json)).toList();

        // Filter playlists with non-zero item counts
        final filteredPlaylists = playlists.where((item) => item.itemCount != 0).toList();
        // Sort filtered playlists by publishedAt date
        filteredPlaylists.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

        // Cache the fetched data in SharedPreferences.
        prefs.setString(cacheKey, response.body);

        return filteredPlaylists;
      } else {
        throw Exception('Failed to load playlists');
      }
    }
  }

  Future<List<YouTubePlaylistItemModel>> fetchPlaylistItems({apiKey,playlistId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'avvento_$playlistId';
    final String? avventoMusicItemCachedData = prefs.getString(cacheKey);

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      if (avventoMusicItemCachedData != null) {
        final data = json.decode(avventoMusicItemCachedData);
        final List<YouTubePlaylistItemModel> cachedItems = List<YouTubePlaylistItemModel>.from(
            data['items'].map((data) => YouTubePlaylistItemModel.fromJson(data))
        );

        // Sort cached items by publish date
        cachedItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return cachedItems;
      } else {
        throw Exception('No cached data available');
      }
    } else {}
    final url = Uri.parse(
      '${AppConstants.youtubePlaylistItemsAPI}?part=snippet&maxResults=50&playlistId=$playlistId&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // Filter out items with private video or with no thumbnails
      final validItems = (json['items'] as List).where((item) {
        final snippet = item['snippet'] ?? {};
        final thumbnails = snippet['thumbnails'] ?? {};
        final defaultThumbnail = thumbnails['maxres'] ?? thumbnails['standard'] ?? thumbnails['high'] ?? {};
        final videoId = snippet['resourceId']?['videoId'] ?? item['id'];

        // Check if the item is a private video or lacks a valid thumbnail
        return snippet['title'] != 'Private video' &&
            videoId.isNotEmpty &&
            (defaultThumbnail['url']?.isNotEmpty ?? false);
      }).toList();

      // Convert filtered items to models
      List<YouTubePlaylistItemModel> items = validItems.map((item) {
        return YouTubePlaylistItemModel.fromJson(item);
      }).toList();

      // Fetch video details including duration
      items = await _fetchVideoDetails(items, apiKey);

      // Sort items by publish date
      items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      // Cache the fetched data in SharedPreferences.
      prefs.setString(cacheKey, response.body);

      return items;
    } else {
      throw Exception('Failed to load playlist items');
    }
  }

  Future<List<YouTubePlaylistItemModel>> _fetchVideoDetails(List<YouTubePlaylistItemModel> items, apiKey) async {
    final videoIds = items.map((item) => item.videoId).join(',');
    final url = '${AppConstants.youtubeVideoAPI}?part=contentDetails,statistics,snippet&id=$videoIds&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videoDetailsMap = {for (var item in data['items']) item['id']: item};

      items = items.map((item) {
        final videoDetails = videoDetailsMap[item.videoId];
        final duration = videoDetails['contentDetails']['duration'];
        final views = videoDetails["statistics"]['viewCount'];
        final liveBroadcastContent = videoDetails['snippet']['liveBroadcastContent'];
        final formattedDuration = formatDuration(duration, liveBroadcastContent);
        return item.copyWith(duration: formattedDuration,liveBroadcastContent: liveBroadcastContent, views: views);
      }).toList();

      return items;
    } else {
      throw Exception('Failed to load video details');
    }
  }

  String formatDuration(String? duration, String? liveBroadcastContent) {
    // If live broadcast content is present or the duration is 'P0D', handle accordingly
    if (liveBroadcastContent != null) {
      if (liveBroadcastContent == 'live') {
        return 'Live'; // Handle live broadcasts specifically
      } else if (liveBroadcastContent == 'upcoming') {
        return 'Premiere'; // Handle scheduled (upcoming) videos
      }
    }

    if (duration == 'P0D') {
      return 'No Duration'; // Handle zero-duration case
    }
    // Duration format from YouTube API is in ISO 8601 (e.g., PT1H3M52S)
    String formattedDuration = '';

    // Remove the 'PT' prefix and 'S' suffix
    duration = duration?.replaceAll('PT', '').replaceAll('S', '');

    // Initialize hours, minutes, and seconds
    int hours = 0, minutes = 0, seconds = 0;

    // Parse hours, minutes, and seconds
    if (duration!.contains('H')) {
      // Format includes hours
      List<String> parts = duration.split('H');
      hours = int.parse(parts[0]);

      if (parts.length > 1) {
        // There are minutes and/or seconds
        String remainder = parts[1];
        if (remainder.contains('M')) {
          List<String> minuteParts = remainder.split('M');
          minutes = int.parse(minuteParts[0]);
          if (minuteParts.length > 1) {
            // There are seconds
            seconds = int.parse(minuteParts[1]);
          }
        } else if (remainder.contains('S')) {
          // Only seconds
          seconds = int.parse(remainder.replaceAll('S', ''));
        }
      }
    } else if (duration.contains('M')) {
      // Format includes minutes and seconds, but no hours
      List<String> parts = duration.split('M');
      minutes = int.parse(parts[0]);

      if (parts.length > 1) {
        // There are seconds
        seconds = int.parse(parts[1].replaceAll('S', ''));
      }
    } else {
      // Only seconds
      seconds = int.parse(duration);
    }

    // Format the duration
    if (hours > 0) {
      formattedDuration =
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      formattedDuration = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      formattedDuration = seconds.toString().padLeft(2, '0');
    }

    return formattedDuration;
  }


}
