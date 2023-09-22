import 'dart:convert';
import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/models/spreakermodels/spreaker_episodes.dart';
import 'package:http/http.dart' as http;

class FetchSpreakerAPI {
  static Future<List<SpreakerEpisode>> fetchEpisodesForShow() async {
    const showId = AppConstants.showId;
    const spreakerUrl = AppConstants.spreakerUrl;

    final url = Uri.parse('$spreakerUrl/$showId/episodes');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print(response);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> episodesData = data['response']['items'];

      // Parse episodes and return them as a list
      final List<SpreakerEpisode> episodes = episodesData
          .map((data) => SpreakerEpisode.fromJson(data))
          .toList();
print(episodes);
      return episodes;
    } else {
      throw Exception('Failed to load episodes');
    }
  }
}