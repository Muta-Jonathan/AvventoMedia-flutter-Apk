import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/presenter_model.dart';

/// Where presenters come from. By default Firestore, filled from the
/// AzuraCast media library by avvento-cache-server (syncPresenters.js).
abstract class PresenterRepository {
  /// The one switch: true uses [ApiPresenterRepository] with
  /// PRESENTERS_API_URL from .env instead of Firestore.
  static const useApi = false;

  static PresenterRepository create() {
    final url = dotenv.isInitialized ? dotenv.env['PRESENTERS_API_URL'] : null;
    return useApi && url != null && url.isNotEmpty
        ? ApiPresenterRepository(url)
        : FirestorePresenterRepository();
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

/// The `presenters` collection: one document per presenter with series and
/// singles, written by avvento-cache-server.
class FirestorePresenterRepository implements PresenterRepository {
  FirestorePresenterRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  /// Resolved on first use, so creating the repository needs no Firebase.
  CollectionReference<Map<String, dynamic>> get _presenters =>
      (_firestore ?? FirebaseFirestore.instance).collection('presenters');

  @override
  Future<List<Presenter>> fetchPresenters() async {
    final snapshot = await _presenters.get();
    return [
      for (final doc in snapshot.docs)
        // The documents are fetched whole anyway; keeping the sermons lets
        // Search find them without a read per presenter.
        Presenter.fromJson(doc.data())
    ]..sort((a, b) => b.sermonCount.compareTo(a.sermonCount));
  }

  @override
  Future<Presenter> fetchPresenter(String id) async {
    final doc = await _presenters.doc(id).get();
    final data = doc.data();
    if (data == null) throw Exception('Presenter $id not found');
    return Presenter.fromJson(data);
  }
}
