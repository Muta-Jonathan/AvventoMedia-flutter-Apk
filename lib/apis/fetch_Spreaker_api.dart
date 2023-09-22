import 'dart:convert';
import 'package:avvento_radio/componets/app_constants.dart';
import 'package:http/http.dart' as http;

class FetchSpreakerAPI {
  static Future<List<Map<String, dynamic>>> fetchEpisodesForShow() async {
    const showId = AppConstants.showId;
    const spreakerUrl = AppConstants.spreakerUrl;

    final url = Uri.parse('$spreakerUrl/$showId/episodes');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> episodes = data['response']['items'];
      return episodes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load episodes');
    }
  }

}