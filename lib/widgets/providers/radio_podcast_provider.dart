import 'package:avvento_media/apis/azuracast_api.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:avvento_media/apis/fetch_spreaker_api.dart';
import 'package:avvento_media/models/spreakermodels/spreaker_episodes.dart';

import '../../models/radiomodel/podcast_episode_model.dart';

class RadioPodcastProvider extends ChangeNotifier {
  List<RadioPodcast> _podcasts = [];
  List<PodcastEpisode> _podcastEpisodes = [];

  List<RadioPodcast> get podcasts => _podcasts;

  List<PodcastEpisode> get podcastEpisodes => _podcastEpisodes;

  Future<void> fetchAllPodcasts() async {
    try {
      _podcasts = await AzuraCastAPI.fetchRadioPodcasts();
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> fetchAllEpisodes(String apiUrl) async {
    try {
      _podcastEpisodes = await AzuraCastAPI.fetchRadioPodcastsEpisodes(apiUrl);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

}
