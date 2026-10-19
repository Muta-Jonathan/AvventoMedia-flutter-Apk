import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> json({Object? lastEpisodeAt}) => {
      'id': 'p',
      'title': 'Wellness Voice',
      'description': '',
      'author': '',
      'is_published': true,
      'episodes': 3,
      'categories': <dynamic>[],
      'art_updated_at': 1000,
      if (lastEpisodeAt != null) 'last_episode_at': lastEpisodeAt,
      'links': {'art': '', 'episodes': ''},
    };

void main() {
  test('lastUpdated follows the newest episode', () {
    final show = RadioPodcast.fromJson(json(lastEpisodeAt: 5000));
    expect(show.lastUpdated.millisecondsSinceEpoch, 5000 * 1000);
  });

  test('falls back to the cover date until the server sends it', () {
    expect(RadioPodcast.fromJson(json()).lastUpdated.millisecondsSinceEpoch,
        1000 * 1000);
    expect(
        RadioPodcast.fromJson(json(lastEpisodeAt: 0))
            .lastUpdated
            .millisecondsSinceEpoch,
        1000 * 1000);
  });
}
