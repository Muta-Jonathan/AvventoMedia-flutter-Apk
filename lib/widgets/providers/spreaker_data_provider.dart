import 'package:flutter/material.dart';
import 'package:avvento_media/apis/fetch_spreaker_api.dart';
import 'package:avvento_media/models/spreakermodels/spreaker_episodes.dart';

class SpreakerEpisodeProvider extends ChangeNotifier {
  List<SpreakerEpisode> _episodes = [];

  List<SpreakerEpisode> get episodes => _episodes;

  Future<void> fetchAllEpisodes() async {
    try {
      _episodes = await FetchSpreakerAPI.fetchEpisodesForShow();
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> fetchEpisodesWithLimits() async {
    try {
      _episodes = await FetchSpreakerAPI.fetchEpisodesForShow(4);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }
}
