import 'package:avvento_media/apis/podcast_repository.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:flutter/material.dart';

class RadioPodcastProvider extends ChangeNotifier {
  RadioPodcastProvider({List<RadioPodcast> podcasts = const []})
      : _podcasts = List.of(podcasts);

  List<RadioPodcast> _podcasts;

  List<RadioPodcast> get podcasts => _podcasts;

  /// The last fetch failed (offline, no cache yet).
  bool failed = false;

  Future<void> fetchAllPodcasts() async {
    try {
      _podcasts = await PodcastRepository.instance.fetchPodcasts();
      failed = false;
    } catch (_) {
      // Keep what we have; only an empty list is a failure.
      failed = _podcasts.isEmpty;
    }
    notifyListeners();
  }
}
