import 'dart:convert';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/models/spreakermodels/spreaker_episodes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FetchSpreakerAPI {
  static Future<List<SpreakerEpisode>> fetchEpisodesForShow() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();

    // Check if episodes are stored in shared preferences
    final String? cachedEpisodes = sharedPreferences.getString('episodes');

    if (connectivityResult == ConnectivityResult.none) {
      // If episodes are cached, parse and return them
      final List<dynamic> episodesData = json.decode(cachedEpisodes!);

      final List<SpreakerEpisode> episodes = episodesData
          .map((data) => SpreakerEpisode.fromJson(data))
          .toList();

      return episodes;
    } else {
      // If episodes are not cached, fetch them from the network
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
        final List<dynamic> episodesData = data['response']['items'];

        // Parse episodes and store them in shared preferences
        final List<SpreakerEpisode> episodes = episodesData
            .map((data) => SpreakerEpisode.fromJson(data))
            .toList();

        // Cache episodes in shared preferences
        await sharedPreferences.setString('episodes', json.encode(episodesData));

        return episodes;
      } else {
        throw Exception('Failed to load episodes');
      }
    }
  }
}
