import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/radiomodel/podcast_episode_model.dart';
import '../models/radiomodel/radio_podcast_model.dart';

/// Where podcasts come from: Firestore, filled from AzuraCast by
/// avvento-cache-server (syncPodcasts.js). Firestore's offline cache keeps
/// shows readable without a connection.
abstract class PodcastRepository {
  static final PodcastRepository instance = FirestorePodcastRepository();

  /// Shows with episodes, most recently updated first.
  Future<List<RadioPodcast>> fetchPodcasts();

  /// The show's episodes as saved on this device, or null. Instant, so the
  /// page can show them while [fetchEpisodes] refreshes.
  Future<List<PodcastEpisode>?> cachedEpisodes(String showId);

  /// Newest first.
  Future<List<PodcastEpisode>> fetchEpisodes(String showId);
}

/// `podcasts/{id}` holds the show; `podcasts/{id}/pages/{n}` its episodes,
/// newest first, 250 per page.
class FirestorePodcastRepository implements PodcastRepository {
  FirestorePodcastRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  /// Resolved on first use, so creating the repository needs no Firebase.
  CollectionReference<Map<String, dynamic>> get _podcasts =>
      (_firestore ?? FirebaseFirestore.instance).collection('podcasts');

  @override
  Future<List<RadioPodcast>> fetchPodcasts() async {
    final snapshot = await _podcasts.get();
    return [for (final doc in snapshot.docs) RadioPodcast.fromJson(doc.data())]
        .where((p) => p.episodes > 0)
        .toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  @override
  Future<List<PodcastEpisode>?> cachedEpisodes(String showId) async {
    try {
      final episodes =
          await _episodes(showId, const GetOptions(source: Source.cache));
      return episodes.isEmpty ? null : episodes;
    } catch (_) {
      return null; // Nothing cached yet.
    }
  }

  @override
  Future<List<PodcastEpisode>> fetchEpisodes(String showId) =>
      _episodes(showId);

  Future<List<PodcastEpisode>> _episodes(String showId,
      [GetOptions? options]) async {
    final pages = await _podcasts
        .doc(showId)
        .collection('pages')
        .orderBy('page')
        .get(options);
    return episodesFromPages([for (final page in pages.docs) page.data()]);
  }
}

/// Joins `pages` documents ({page, episodes}) into one list, newest first.
List<PodcastEpisode> episodesFromPages(List<Map<String, dynamic>> pages) => [
      for (final page in pages)
        for (final e in page['episodes'] as List)
          PodcastEpisode.fromJson(Map<String, dynamic>.from(e))
    ]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
