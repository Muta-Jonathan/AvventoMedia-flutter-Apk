import 'package:avvento_media/apis/azuracast_api.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:avvento_media/apis/fetch_spreaker_api.dart';
import 'package:avvento_media/models/spreakermodels/spreaker_episodes.dart';

class RadioPodcastProvider extends ChangeNotifier {
  List<RadioPodcast> _podcasts = [];

  List<RadioPodcast> get podcasts => _podcasts;

  Future<void> fetchAllEpisodes() async {
    try {
      _podcasts = await AzuraCastAPI.fetchRadioPodcasts();
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

}
