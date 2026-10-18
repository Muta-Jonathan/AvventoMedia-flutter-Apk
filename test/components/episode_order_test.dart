import 'package:avvento_media/components/episode_order.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:flutter_test/flutter_test.dart';

PodcastEpisode ep(String id, String title, {int? number}) => PodcastEpisode(
      id: id,
      title: title,
      description: '',
      playlistMediaArtist: '',
      playlistMediaAlbum: '',
      publishedAt: 0,
      downloadLink: '',
      publicLink: '',
      isPublished: true,
      art: '',
      media: '',
      episodeNumber: number,
    );

void main() {
  test('reads part and chapter numbers from titles', () {
    expect(episodeNumber('Victory Amidst Troubles Pt. 3'), 3);
    expect(episodeNumber('Final Forerunner Part 12'), 12);
    expect(episodeNumber('Ch. 1 – Why Was Sin Permitted?'), 1);
    expect(episodeNumber('Chapter 7: The Flood'), 7);
    expect(episodeNumber('Episode 312'), 312);
    expect(episodeNumber('Genesis 2'), 2);
    expect(episodeNumber('Grace That Is Greater'), isNull);
  });

  test('AzuraCast episode numbers win over the title', () {
    expect(seriesNumber(ep('a', 'Intro 9', number: 1)), 1);
    expect(seriesNumber(ep('a', 'Intro 9')), 9);
  });

  test('numbered series default to in order; daily shows do not', () {
    expect(
        looksLikeSeries(
            [ep('1', 'Faith Pt. 1'), ep('2', 'Faith Pt. 2'), ep('3', 'Q&A')]),
        isTrue);
    expect(
        looksLikeSeries([ep('1', 'Episode 311'), ep('2', 'Episode 312')]),
        isFalse);
    expect(looksLikeSeries([ep('1', 'Faith Pt. 1')]), isFalse);
  });

  test('in order sorts by number; unnumbered go last in publish order', () {
    // Newest first, as the API returns them.
    final api = [
      ep('x', 'Bonus'),
      ep('b', 'Faith Pt. 2'),
      ep('c', 'Faith Pt. 3'),
      ep('a', 'Faith Pt. 1'),
    ];
    List<String> ids(EpisodeSort s) =>
        sortEpisodes(api, s).map((e) => e.id).toList();

    expect(ids(EpisodeSort.inOrder), ['a', 'b', 'c', 'x']);
    expect(ids(EpisodeSort.newest), ['x', 'b', 'c', 'a']);
    expect(ids(EpisodeSort.oldest), ['a', 'c', 'b', 'x']);
  });
}
