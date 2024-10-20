import 'dart:convert';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';

class YouTubeApiService {
  Duration cacheDuration = const Duration(hours: 24);
  final int currentTime = DateTime.now().millisecondsSinceEpoch;

  Future<List<YoutubePlaylistModel>> fetchPlaylists({apiKey,channelId, int maxResults = 50, int totalResults = 200, }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'avvento_$channelId';
    final String? avventoCachedData = prefs.getString(cacheKey);
    List<YoutubePlaylistModel> allPlaylists = [];
    final int? cachedTimestamp = prefs.getInt('${cacheKey}_timestamp');

    // Check if cached data exists and hasn't expired
    if (avventoCachedData != null && cachedTimestamp != null) {
      final int cacheExpirationTime = cachedTimestamp + cacheDuration.inMilliseconds;
      if (currentTime < cacheExpirationTime) {
        final data = json.decode(avventoCachedData);
        final List<YoutubePlaylistModel> cachedPlaylists = List<YoutubePlaylistModel>.from(
            data['items'].map((data) => YoutubePlaylistModel.fromJson(data))
        );

        // Filter playlists with non-zero item counts
        final filteredPlaylists = cachedPlaylists.where((item) => item.itemCount != 0).toList();
        // Sort filtered playlists by publishedAt date
        filteredPlaylists.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

        return filteredPlaylists;
      }
    }
    String? nextPageToken;
    int fetchedResults = 0;

    do {
      // Build the URL with pagination
      final baseUrl =
          '${AppConstants.youtubePlaylistAPI}?part=snippet,contentDetails&channelId=$channelId&maxResults=$maxResults&key=$apiKey';
      final url = nextPageToken != null ? '$baseUrl&pageToken=$nextPageToken' : baseUrl;

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> items = data['items'];
        final List<YoutubePlaylistModel> playlists = await Future.wait(items.map((json) async {
          final YoutubePlaylistModel playlist = YoutubePlaylistModel.fromJson(json);

          // Fetch playlist items using fetchPlaylistItems to get the non-private items
          final List<YouTubePlaylistItemModel> playlistItems = await fetchPlaylistItems(
            apiKey: apiKey,
            playlistId: playlist.id,
            maxResults: 70,
          );

          // Update the itemCount based on the non-private items
          return playlist.updateItemCountBasedOnNonPrivateItems(playlistItems);
        }).toList());

        // Add to total fetched playlists
        allPlaylists.addAll(playlists);

        // Check for pagination token
        nextPageToken = data['nextPageToken'];

        // Increment the fetched results count
        fetchedResults += items.length;

      } else {
        throw Exception('Failed to load playlists');
      }

    } while (nextPageToken != null && fetchedResults < totalResults); // Continue if more items to fetch

    // Filter playlists with non-zero item counts
    final finalPlaylists = allPlaylists.where((item) => item.itemCount != 0).toList();
    // Sort filtered playlists by publishedAt date
    finalPlaylists.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Cache the fetched data in SharedPreferences.
    prefs.setString(cacheKey, json.encode(allPlaylists));

    return finalPlaylists;
  }

  Future<List<YouTubePlaylistItemModel>> fetchPlaylistItems({apiKey,playlistId,int maxResults = 50,}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'avvento_$playlistId';
    final String? avventoItemCachedData = prefs.getString(cacheKey);
    final int? cachedTimestamp = prefs.getInt('${cacheKey}_timestamp');
    cacheDuration = const Duration(hours: 4);

    if (avventoItemCachedData != null && cachedTimestamp != null) {
      final int cacheExpirationTime = cachedTimestamp + cacheDuration.inMilliseconds;
      if (currentTime < cacheExpirationTime) {
        final data = json.decode(avventoItemCachedData);
        final List<YouTubePlaylistItemModel> cachedItems = List<
            YouTubePlaylistItemModel>.from(
            data['items'].map((data) => YouTubePlaylistItemModel.fromJson(data))
        );

        // Sort cached items by publish date
        cachedItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return cachedItems;
      }
    }

    final url = Uri.parse(
      '${AppConstants.youtubePlaylistItemsAPI}?part=snippet,status&maxResults=$maxResults&playlistId=$playlistId&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // Filter out items with private video or with no thumbnails
      final validItems = (json['items'] as List).where((item) {
        final snippet = item['snippet'] ?? {};
        final status = item['status'] ?? {};
        final thumbnails = snippet['thumbnails'] ?? {};
        final defaultThumbnail = thumbnails['maxres'] ?? thumbnails['standard'] ?? thumbnails['high'] ?? {};
        final videoId = snippet['resourceId']?['videoId'] ?? item['id'];

        // Check if the item is a private video or lacks a valid thumbnail
        return snippet['title'] != 'Private video' &&
            videoId.isNotEmpty && status['privacyStatus'] == 'public' &&
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
    final url = '${AppConstants.youtubeVideoAPI}?part=contentDetails,status,statistics,snippet&id=$videoIds&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videoDetailsMap = {for (var item in data['items']) item['id']: item};

      items = items.map((item) {
        final videoDetails = videoDetailsMap[item.videoId];
        final duration = videoDetails['contentDetails']['duration'];
        final views = videoDetails["statistics"]['viewCount'];
        final liveBroadcastContent = videoDetails['snippet']['liveBroadcastContent'];
        final privacyStatus = videoDetails['status']['privacyStatus'];
        final formattedDuration = formatDuration(duration, liveBroadcastContent);
        return item.copyWith(duration: formattedDuration,liveBroadcastContent: liveBroadcastContent, views: views, privacyStatus: privacyStatus);
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

    if (duration == null || duration == 'P0D') {
      return 'No Duration'; // Handle zero-duration case
    }
    // Duration format from YouTube API is in ISO 8601 (e.g., PT1H3M52S)
    String formattedDuration = '';

    // Remove the 'PT' prefix and 'S' suffix
    duration = duration.replaceAll('PT', '').replaceAll('S', '');

    // Initialize hours, minutes, and seconds
    int hours = 0, minutes = 0, seconds = 0;

    // Parse hours
    if (duration.contains('H')) {
      List<String> parts = duration.split('H');
      hours = int.parse(parts[0]);
      duration = parts.length > 1 ? parts[1] : '';
    }

    // Parse minutes
    if (duration.contains('M')) {
      List<String> parts = duration.split('M');
      minutes = int.parse(parts[0]);
      duration = parts.length > 1 ? parts[1] : '';
    }

    // Parse seconds
    if (duration.isNotEmpty) {
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
