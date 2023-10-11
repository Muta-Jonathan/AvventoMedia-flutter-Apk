import 'dart:convert';
import 'package:avvento_radio/componets/app_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/radiomodel/radio_station_model.dart';

class AzuraCastAPI {
  static WebSocketChannel? _channel;

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

  static Stream<RadioStation>? getRadioStationUpdates() {
    return _channel?.stream.map((data) {
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

        return RadioStation(
          artist: artist ?? '',
          imageUrl: imageUrl ?? '',
          nowPlayingTitle: nowPlayingTitle ?? '',
          streamUrl: streamUrl ?? '',
          elapsed: elapsed ?? 0,
          duration: duration ?? 0,
        );
      } catch (e) {
        print('Error parsing JSON data: $e');
        return RadioStation(
          artist: '', // Provide default values in case of an error
          imageUrl: '',
          nowPlayingTitle: '',
          streamUrl: '',
          elapsed: 0,
          duration: 0,
        ); // Return a null object or handle the error as needed
      }
    });
  }



  static void closeWebsocketConnection() {
    _channel?.sink.close();
  }
}
