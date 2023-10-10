import 'dart:convert';
import 'package:http/http.dart' as http;

import '../componets/app_constants.dart';
import '../models/radiomodel/radio_station_model.dart';

class AzuraCastAPI {

  static Future<RadioStation> fetchRadioStation() async {
    const String apiUrl = AppConstants.azuracastAPI;

    final url = Uri.parse(apiUrl);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);

      final artist = jsonResult['now_playing']['song']['artist'];
      final imageUrl = jsonResult['now_playing']['song']['art'];
      final nowPlayingTitle = jsonResult['now_playing']['song']['title'];
      final streamUrl = jsonResult['station']['listen_url'];

      return RadioStation(
        artist: artist,
        imageUrl: imageUrl,
        nowPlayingTitle: nowPlayingTitle,
        streamUrl: streamUrl,
      );
    } else {
      throw Exception('Failed to load radio station data');
    }
  }
}
