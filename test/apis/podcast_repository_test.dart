import 'package:avvento_media/apis/podcast_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> episode(String id, int publishAt) => {
      'id': id,
      'title': 'Episode $id',
      'description': '',
      'playlist_media': {'artist': '', 'album': ''},
      'publish_at': publishAt,
      'links': {'download': '', 'public': '', 'media': ''},
      'is_published': true,
      'art': '',
      'episode_number': null,
      'season_number': null,
    };

void main() {
  test('joins episode pages newest first', () {
    final episodes = episodesFromPages([
      {
        'page': 0,
        'episodes': [episode('c', 300), episode('b', 200)]
      },
      {
        'page': 1,
        'episodes': [episode('a', 100), episode('d', 400)]
      },
    ]);
    expect(episodes.map((e) => e.id), ['d', 'c', 'b', 'a']);
  });

  test('clears the old SharedPreferences podcast copies only', () async {
    SharedPreferences.setMockInitialValues({
      'cachedRadioPodcastKey': '[]',
      'cachedPodcastEpisodeKey:https://x/podcast/1/episodes': '[]',
      'cachedRadioStationKey': '{}',
    });
    await PodcastRepository.clearLegacyCache();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {'cachedRadioStationKey'});
  });
}
