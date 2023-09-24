import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exploremodels/programs.dart';
import 'package:http/http.dart' as http;

class ExploreDataFetcher {
  static Future<List<Programs>> fetchPrograms() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('cached_data');

    if (cachedData != null) {
      final data = json.decode(cachedData);
      return List<Programs>.from(data['programs'].map((data) => Programs.fromJson(data)));
    } else {
      final url = Uri.https(
        'raw.githubusercontent.com',
        '/Muta-Jonathan/AvventoRadio-flutter-Apk/main/assets/temp.json',
        {'q': '{https}'},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cache the fetched data in SharedPreferences.
        prefs.setString('cached_data', response.body);

        return List<Programs>.from(data['programs'].map((data) => Programs.fromJson(data)));
      } else {
        throw Exception('Failed to load data');
      }
    }
  }
}
