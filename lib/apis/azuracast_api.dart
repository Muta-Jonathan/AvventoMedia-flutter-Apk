import 'dart:convert';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/radiomodel/radio_station_model.dart';
import 'package:http/http.dart' as http;

class AzuraCastAPI {
  static WebSocketChannel? _channel;

  // SharedPreferences key for caching
  static const _cachedRadioStationKey = 'cachedRadioStationKey';
  static const _cachedRadioPodcastKey = 'cachedRadioPodcastKey';
  static const _cachedPodcastEpisodeKey = 'cachedPodcastEpisodeKey';
  static String? azuracastAPIKey = dotenv.env["AZURACAST_APIKEY"];

  /// The API key for AzuraCast's private media links (sermons from the
  /// media library, `/api/station/…/file/{id}/play`); none for public URLs.
  static Map<String, String>? mediaHeaders(String url) {
    if (!RegExp(r'/api/station/[^/]+/file/\d+').hasMatch(url)) return null;
    final key = dotenv.isInitialized ? dotenv.env['AZURACAST_APIKEY'] : null;
    return key == null || key.isEmpty ? null : {'X-API-Key': key.trim()};
  }

  static void establishWebsocketConnection() {
    _channel = WebSocketChannel.connect(
      Uri.parse(AppConstants.azuracastWebSocketAPI),
    );
  }

  static void sendInitialMessage() {
    // Create a JSON message and send it to the WebSocket server
    final message = {
      "subs": {"station:avventoradio": {"recover": true}}
    };
    _channel?.sink.add(jsonEncode(message));
  }

  static Stream<RadioStation> getRadioStationUpdates() {
    // Non-station messages (e.g. the connect reply) map to null and are
    // dropped, so listeners never get an empty station.
    return _channel!.stream.asyncMap<RadioStation?>((data) async {
      try {
        final jsonResult = json.decode(data);

        final np = jsonResult['pub']['data']['np'];
        final stationData = np['station'];
        final nowPlaying = np['now_playing'];
        final playingNext = np['playing_next'];

        final id = nowPlaying['sh_id'];
        final artist = nowPlaying['song']['artist'];
        final imageUrl = nowPlaying['song']['art'];
        final streamUrl = stationData['listen_url'];
        final nowPlayingTitle = nowPlaying['song']['title'];
        final elapsed = nowPlaying['elapsed'];
        final duration = nowPlaying['duration'];
        final playingNextProgram = playingNext['song']['text'];


        final radioStation = RadioStation(
          id: id ?? '',
          artist: artist ?? '',
          imageUrl: imageUrl ?? '',
          nowPlayingTitle: nowPlayingTitle ?? '',
          streamUrl: streamUrl ?? '',
          elapsed: elapsed ?? 0,
          duration: duration ?? 0,
          nextProgram: playingNextProgram != null ? 'Next: $playingNextProgram' : '',
        );

        // Store the retrieved data in SharedPreferences
        await _cacheRadioStationData(radioStation);

        return radioStation;
      } catch (e) {

        return _loadCachedRadioStationData();
      }
    }).where((station) => station != null).cast<RadioStation>();
  }

  static Future<void> _cacheRadioStationData(RadioStation radioStation) async {
    final prefs = await SharedPreferences.getInstance();
    final radioStationJson = radioStation.toJson();
    await prefs.setString(_cachedRadioStationKey, json.encode(radioStationJson));
  }

  static Future<RadioStation?> _loadCachedRadioStationData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cachedRadioStationKey);
    if (cachedData != null) {
      final cachedRadioStationMap = json.decode(cachedData);
      return RadioStation.fromJson(cachedRadioStationMap);
    }
    return null; // Return null if no cached data is available
  }

  static void closeWebsocketConnection() {
    _channel?.sink.close();
  }

  //fetch radio podcasts from avventoRadio
  static Future<List<RadioPodcast>> fetchRadioPodcasts() async {
    String apiUrl = AppConstants.azuracastPodcastAPI;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_cachedRadioPodcastKey);

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (cachedData == null) throw Exception('No cached podcasts');
      final data = json.decode(cachedData);
      final List<RadioPodcast> cachedPodcasts = List<RadioPodcast>.from(data.map((data) => RadioPodcast.fromJson(data)));
      // Filter podcasts with non-zero episodes
      final filteredPodcasts = cachedPodcasts.where((podcast) => podcast.episodes > 0).toList();
      // Resort the filtered episodes
      filteredPodcasts.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      return filteredPodcasts;
    } else {
      final url = Uri.parse(apiUrl);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $azuracastAPIKey'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);

        // Cache the fetched data in SharedPreferences.
        prefs.setString(_cachedRadioPodcastKey, response.body);

        // Create a list of RadioPodcast objects from the JSON data
        final radioPodcasts = jsonResult.map((json) => RadioPodcast.fromJson(json)).toList();

        // Filter podcasts with non-zero episodes
        final filteredPodcasts = radioPodcasts.where((podcast) => podcast.episodes > 0).toList();

        // Sort the filtered podcasts by lastUpdated date
        filteredPodcasts.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

        return filteredPodcasts;
      } else {
        throw Exception('Failed to load radio podcast data');
      }
    }
  }

  /// The show's episodes saved on the last visit, or null. The page shows
  /// them at once while [fetchRadioPodcastsEpisodes] refreshes.
  static Future<List<PodcastEpisode>?> cachedRadioPodcastsEpisodes(
      String apiUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_cachedPodcastEpisodeKey:$apiUrl');
    return cached == null ? null : compute(_parseEpisodes, cached);
  }

  /// Newest first. Runs in a background isolate: the Old Testament is
  /// about 1.3 MB of JSON.
  static List<PodcastEpisode> _parseEpisodes(String body) =>
      (json.decode(body) as List)
          .map((item) => PodcastEpisode.fromJson(item))
          .toList()
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

  //fetch radio podcasts episodes from avventoRadio
  static Future<List<PodcastEpisode>> fetchRadioPodcastsEpisodes(String apiUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Per show, so offline never shows another show's episodes.
    final cacheKey = '$_cachedPodcastEpisodeKey:$apiUrl';
    final String? cachedData = prefs.getString(cacheKey);

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (cachedData == null) throw Exception('No cached episodes');
      return compute(_parseEpisodes, cachedData);
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $azuracastAPIKey'
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load radio podcast data');
    }
    // Rewriting 1 MB+ on every visit is wasted work when nothing changed.
    if (response.body != cachedData) {
      await prefs.setString(cacheKey, response.body);
    }
    return compute(_parseEpisodes, response.body);
  }
}
