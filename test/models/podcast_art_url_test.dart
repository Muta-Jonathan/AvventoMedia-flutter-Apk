import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = 'https://radio1.avventomedia.org/api/station';

  test('private AzuraCast art becomes the public route', () {
    expect(publicArtUrl('$base/1/podcast/abc/art-1.jpg'),
        '$base/1/public/podcast/abc/art-1.jpg');
    expect(publicArtUrl('$base/avventoradio/podcast/abc/episode/e1/art-2.jpg'),
        '$base/avventoradio/public/podcast/abc/episode/e1/art-2.jpg');
  });

  test('public and other URLs are left alone', () {
    const public = '$base/1/public/podcast/abc/art-1.jpg';
    expect(publicArtUrl(public), public);
    expect(publicArtUrl('https://example.org/cover.png'),
        'https://example.org/cover.png');
    expect(publicArtUrl(''), '');
  });

  test('episodes parsed from the API get public art', () {
    final episode = PodcastEpisode.fromJson({
      'id': 'e1',
      'title': 'Lawlessness Abounds',
      'description': '',
      'playlist_media': {'artist': 'Amazing Facts', 'album': 'Devotional'},
      'publish_at': 0,
      'links': {'download': '', 'public': '', 'media': ''},
      'is_published': true,
      'art': '$base/1/podcast/abc/episode/e1/art-2.jpg',
    });
    expect(episode.art, '$base/1/public/podcast/abc/episode/e1/art-2.jpg');
  });
}
