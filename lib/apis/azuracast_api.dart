import 'dart:convert';
import 'package:avvento_media/components/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/radiomodel/radio_station_model.dart';

class AzuraCastAPI {
  static WebSocketChannel? _channel;

  // SharedPreferences key for caching
  static const _cachedRadioStationKey = 'cachedRadioStationKey';
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
}
