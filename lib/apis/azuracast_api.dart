import 'dart:convert';
import 'package:avvento_radio/componets/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/radiomodel/radio_station_model.dart';

class AzuraCastAPI {
  static WebSocketChannel? _channel;

  // SharedPreferences key for caching
  static const _cachedRadioStationKey = 'cachedRadioStationKey';

  static void establishWebsocketConnection() {
    _channel = WebSocketChannel.connect(
      Uri.parse(AppConstants.azuracastWebSocketAPI),
    );
  }

  static void sendInitialMessage() {
    // Create a JSON message and send it to the WebSocket server
    final message = {
      "subs": {"station:avventoradio": {}}
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

        final artist = nowPlaying['song']['artist'];
        final imageUrl = nowPlaying['song']['art'];
        final streamUrl = stationData['listen_url'];
        final nowPlayingTitle = nowPlaying['song']['title'];
        final elapsed = nowPlaying['elapsed'];
        final duration = nowPlaying['duration'];

        final radioStation = RadioStation(
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
        print('Error parsing JSON data: $e');

        // Load cached data if available, or provide default values
        final cachedRadioStation = await _loadCachedRadioStationData();
        return cachedRadioStation ?? RadioStation(
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
}
