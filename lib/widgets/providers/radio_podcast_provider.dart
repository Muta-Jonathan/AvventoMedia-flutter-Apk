import 'package:avvento_media/apis/podcast_repository.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:flutter/material.dart';

class RadioPodcastProvider extends ChangeNotifier {
  List<RadioPodcast> _podcasts = [];

  List<RadioPodcast> get podcasts => _podcasts;

  Future<void> fetchAllPodcasts() async {
    try {
      _podcasts = await PodcastRepository.instance.fetchPodcasts();
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }
}
