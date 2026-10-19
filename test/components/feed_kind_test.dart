import 'package:avvento_media/components/episode_order.dart';
import 'package:avvento_media/components/feed_kind.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:flutter_test/flutter_test.dart';

PodcastEpisode ep(String title, {int? season, int? number}) => PodcastEpisode(
      id: title,
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
      seasonNumber: season,
      episodeNumber: number,
    );

void main() {
  test('reads book and chapter from Bible titles', () {
    final ref = bibleRef(ep('Genesis 1'))!;
    expect(ref.bibleBook.name, 'Genesis');
    expect(ref.chapter, 1);
    expect(bibleRef(ep('Song of Solomon 3'))!.book, 22);
    expect(bibleRef(ep('1 Samuel 2'))!.book, 9);
    expect(bibleRef(ep('Psalm 23'))!.bibleBook.name, 'Psalms');
    expect(bibleRef(ep('Revelation 22'))!.newTestament, isTrue);
    expect(bibleRef(ep('Grace That Is Greater')), isNull);
    expect(bibleRef(ep('Faith Pt. 2')), isNull);
  });

  test('works out the feed kind from the episodes', () {
    expect(
        feedKindOf(
            'Old Testament KJV Dramatized', [ep('Genesis 2'), ep('Genesis 1')]),
        FeedKind.bible);
    expect(
        feedKindOf('Patriarchs and Prophets (Dramatized)', [
          ep('Ch. 2 - The Creation (Patriarchs and Prophets)'),
          ep('Ch. 1 - Why Was Sin Permitted (Patriarchs and Prophets)'),
        ]),
        FeedKind.egwBook);
    expect(feedKindOf('Faith', [ep('Faith Pt. 1'), ep('Faith Pt. 2')]),
        FeedKind.series);
    expect(feedKindOf('Daily', [ep('Episode 311'), ep('Episode 312')]),
        FeedKind.show);
    expect(feedKindOf('Empty', const []), FeedKind.show);
  });

  test('Bible in order is book then chapter, not chapter alone', () {
    // AzuraCast numbers chapters per book, so episode numbers repeat.
    final api = [
      ep('Exodus 2', season: 2, number: 2),
      ep('Exodus 1', season: 2, number: 1),
      ep('Genesis 2', season: 1, number: 2),
      ep('Genesis 1', season: 1, number: 1),
    ];
    expect(
        sortEpisodes(api, EpisodeSort.inOrder, kind: FeedKind.bible)
            .map((e) => e.title),
        ['Genesis 1', 'Genesis 2', 'Exodus 1', 'Exodus 2']);
    // Season then number works for any numbered show.
    expect(sortEpisodes(api, EpisodeSort.inOrder).map((e) => e.title),
        ['Genesis 1', 'Genesis 2', 'Exodus 1', 'Exodus 2']);
  });

  test('EGW rows drop the repeated book name', () {
    final e = ep('Ch. 1 - Why Was Sin Permitted (Patriarchs and Prophets)');
    expect(episodeDisplayTitle(e, FeedKind.egwBook),
        'Ch. 1 – Why Was Sin Permitted');
    expect(episodeDisplayTitle(e, FeedKind.show), e.title);
  });

  test('overline leads', () {
    expect(episodeNumberLead(ep('Genesis 3'), FeedKind.bible), 'Chapter 3');
    expect(episodeNumberLead(ep('Ch. 2 - The Creation'), FeedKind.egwBook),
        'Chapter 2');
    expect(episodeNumberLead(ep('Faith Pt. 4'), FeedKind.series), 'Part 4');
    expect(episodeNumberLead(ep('Faith Pt. 4'), FeedKind.show), isNull);
  });

  test('default sort', () {
    expect(defaultSort(FeedKind.bible), EpisodeSort.inOrder);
    expect(defaultSort(FeedKind.egwBook), EpisodeSort.inOrder);
    expect(defaultSort(FeedKind.series), EpisodeSort.inOrder);
    expect(defaultSort(FeedKind.show), EpisodeSort.newest);
  });

  test('the Listen home splits the real shows by title', () {
    const inOrder = [
      'Old Testament KJV Dramatized',
      'New Testament KJV Dramatized',
      'Psalms KJV Dramatized',
      'Proverbs KJV Dramatized',
      'The Desire of Ages (Dramatized)',
      'Patriarchs and Prophets (Dramatized)',
      "Children's Bible Journey",
      'Manya Baibuli',
    ];
    const daily = [
      'Amazing Facts Daily Devotional',
      'Devotions by Denis Mukaisa',
      "Eriiso Ly'Obunnabbi",
      'Maranatha – Daily Readings',
      'Wellness Voice',
      'Rendezvous – Stories of Faith',
    ];
    expect(inOrder.where((t) => !playsInOrderByTitle(t)), isEmpty);
    expect(daily.where(playsInOrderByTitle), isEmpty);
  });
}
