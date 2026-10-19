import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/presenter_model.dart';
import 'mock_presenter_repository.dart';

/// Where presenters come from.
abstract class PresenterRepository {
  /// The one switch: true uses [ApiPresenterRepository] with
  /// PRESENTERS_API_URL from .env (falls back to the mock if it's unset).
  static const useApi = false;

  static PresenterRepository create() {
    final url = dotenv.isInitialized ? dotenv.env['PRESENTERS_API_URL'] : null;
    return useApi && url != null && url.isNotEmpty
        ? ApiPresenterRepository(url)
        : MockPresenterRepository();
  }

  /// Summaries, most sermons first.
  Future<List<Presenter>> fetchPresenters();

  /// One presenter with series and singles.
  Future<Presenter> fetchPresenter(String id);
}

/// GET {base}/presenters → summaries; GET {base}/presenters/{id} → detail.
/// Sermons use AzuraCast's episode JSON, so playback and downloads work
/// unchanged.
class ApiPresenterRepository implements PresenterRepository {
  ApiPresenterRepository(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<dynamic> _get(String path) async {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final response = await _client.get(Uri.parse('$base$path'));
    if (response.statusCode != 200) {
      throw Exception('Presenters API ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  @override
  Future<List<Presenter>> fetchPresenters() async {
    final list = await _get('/presenters') as List;
    return [for (final p in list) Presenter.fromJson(p)]
      ..sort((a, b) => b.sermonCount.compareTo(a.sermonCount));
  }

  @override
  Future<Presenter> fetchPresenter(String id) async =>
      Presenter.fromJson(await _get('/presenters/$id'));
}
