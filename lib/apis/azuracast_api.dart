import 'dart:convert';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    return _channel!.stream.asyncMap((data) async {
      try {
        final jsonResult = json.decode(data);

        final np = jsonResult['pub']['data']['np'];
        final stationData = np['station'];
        final nowPlaying = np['now_playing'];

        final id = nowPlaying['sh_id'];
        final artist = nowPlaying['song']['artist'];
        final imageUrl = nowPlaying['song']['art'];
        final streamUrl = stationData['listen_url'];
        final nowPlayingTitle = nowPlaying['song']['title'];
        final elapsed = nowPlaying['elapsed'];
        final duration = nowPlaying['duration'];

        final radioStation = RadioStation(
          id: id ?? '',
          artist: artist ?? '',
          imageUrl: imageUrl ?? '',
          nowPlayingTitle: nowPlayingTitle ?? '',
          streamUrl: streamUrl ?? '',
          elapsed: elapsed ?? 0,
          duration: duration ?? 0,
        );

        // Store the retrieved data in SharedPreferences
        await _cacheRadioStationData(radioStation);

        return radioStation;
      } catch (e) {

        // Load cached data if available, or provide default values
        final cachedRadioStation = await _loadCachedRadioStationData();
        return cachedRadioStation ?? RadioStation(
          id: 0,
          artist: '', // Provide default values in case of an error
          imageUrl: '',
          nowPlayingTitle: '',
          streamUrl: '',
          elapsed: 0,
          duration: 0,
        );
      }
    });
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

    if (connectivityResult == ConnectivityResult.none) {
      final data = json.decode(cachedData!);
      return List<RadioPodcast>.from(data.map((data) => RadioPodcast.fromJson(data)));
    } else {
      final url = Uri.parse(apiUrl);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.azuracastAPIKey}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);


        // Cache the fetched data in SharedPreferences.
        prefs.setString(_cachedRadioPodcastKey, response.body);

        // Create a list of RadioPodcast objects from the JSON data
        final radioPodcasts = jsonResult.map((json) => RadioPodcast.fromJson(json)).toList()
          ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

        return radioPodcasts;
      } else {
        throw Exception('Failed to load radio podcast data');
      }
    }
  }

  //fetch radio podcasts episodes from avventoRadio
  static Future<List<PodcastEpisode>> fetchRadioPodcastsEpisodes(String apiUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_cachedPodcastEpisodeKey);

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      final data = json.decode(cachedData!);
      return List<PodcastEpisode>.from(data.map((data) => RadioPodcast.fromJson(data)));
    } else {
      final url = Uri.parse(apiUrl);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.azuracastAPIKey}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);


        // Cache the fetched data in SharedPreferences.
        prefs.setString(_cachedPodcastEpisodeKey, response.body);

        // Create a list of RadioPodcast objects from the JSON data
        final podcastEpisodes = jsonResult.map((json) => PodcastEpisode.fromJson(json)).toList();

        // Sort episodes by publish_at timestamp
        podcastEpisodes.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

        return podcastEpisodes;
      } else {
        throw Exception('Failed to load radio podcast data');
      }
    }
  }


}
