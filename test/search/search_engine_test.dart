import 'package:avvento_media/search/search_engine.dart';
import 'package:avvento_media/search/search_filters.dart';
import 'package:avvento_media/search/search_models.dart';
import 'package:flutter_test/flutter_test.dart';

final now = DateTime(2026, 10, 20);

SearchEntry entry(
  SearchKind kind,
  String title, {
  String id = '',
  String presenter = '',
  String subtitle = '',
  String source = SearchSources.radio,
  int? daysAgo,
  int? minutes,
  String keywords = '',
  int count = 0,
}) =>
    SearchEntry(
      kind: kind,
      id: id.isEmpty ? title : id,
      title: title,
      presenter: presenter,
      subtitle: subtitle,
      source: source,
      publishedAt:
          daysAgo == null ? null : now.subtract(Duration(days: daysAgo)),
      duration: minutes == null ? null : Duration(minutes: minutes),
      keywords: keywords,
      count: count,
      payload: title,
    );

void main() {
  group('matching', () {
    test('normalizes case, accents and punctuation', () {
      expect(SearchEngine.normalize('  Daniel’s  Prayer! '), 'daniels prayer');
      expect(SearchEngine.normalize('Café'), 'cafe');
    });

    test('presenters match with and without their title', () {
      final e = entry(SearchKind.presenter, 'Pr. Okello Samuel');
      expect(SearchEngine.score(e, 'okello'), greaterThan(0));
      expect(SearchEngine.score(e, 'Pr. Okello'), greaterThan(0));
      expect(SearchEngine.score(e, 'okello samuel'), 100);
    });

    test('exact beats prefix beats a word start beats contains', () {
      int s(String title) =>
          SearchEngine.score(entry(SearchKind.sermon, title), 'daniel');
      expect(s('Daniel'), 100);
      expect(s('Daniel Speaks Today'), 85);
      expect(s('The Book of Daniel'), 70);
      expect(s('Abdaniel'), 55);
      expect(s('Grace'), 0);
    });

    test('finds by presenter, subtitle and keywords', () {
      final e = entry(SearchKind.sermon, 'The Image',
          presenter: 'Pr. Okello Samuel', keywords: 'dream statue');
      expect(SearchEngine.score(e, 'statue'), 30);
      expect(SearchEngine.score(e, 'image okello'), 45);
    });
  });

  group('results', () {
    final entries = [
      entry(SearchKind.presenter, 'Pr. Okello Samuel', count: 37),
      entry(SearchKind.presenter, 'Pr. Wasoga Moses', count: 31),
      entry(SearchKind.presenter, 'Ev. Denis Mukaisa'),
      entry(SearchKind.series, 'Daniel Speaks Today',
          presenter: 'Pr. Okello Samuel', daysAgo: 30),
      entry(SearchKind.podcast, 'Old Testament KJV Dramatized',
          keywords: 'daniel'),
      for (var i = 1; i <= 4; i++)
        entry(SearchKind.sermon, 'Daniel Part $i',
            id: 's$i',
            presenter: 'Pr. Okello Samuel',
            daysAgo: 10 * i,
            minutes: 30 + i),
      entry(SearchKind.episode, 'Daniel 6', id: 'e1', daysAgo: 400, minutes: 7),
      entry(SearchKind.video, 'Daniel and Revelation Seminar',
          source: SearchSources.main, daysAgo: 100, minutes: 72),
      entry(SearchKind.video, 'Dare to Be a Daniel',
          source: SearchSources.kids, daysAgo: 5, minutes: 4),
      entry(SearchKind.playlist, 'Daniel Playlist',
          source: SearchSources.main, count: 7),
      entry(SearchKind.live, 'AvventoRadio', keywords: 'daniel'),
    ];

    SearchResults run(String q,
            {SearchTab tab = SearchTab.all,
            SearchFilters filters = SearchFilters.none,
            Set<String> downloaded = const {}}) =>
        SearchEngine.search(entries, q,
            tab: tab,
            filters: filters,
            now: now,
            isDownloaded: downloaded.contains);

    test('counts matches per tab', () {
      final r = run('daniel');
      expect(r.counts[SearchTab.sermons], 5);
      expect(r.counts[SearchTab.videos], 3);
      expect(r.counts[SearchTab.podcasts], 2);
      expect(r.counts[SearchTab.live], 1);
      // Okello matches through his four Daniel sermons.
      expect(r.counts[SearchTab.presenters], 1);
    });

    test('a presenter matches when three or more of their sermons do', () {
      final r = run('daniel');
      final okello = r.of(SearchKind.presenter).single;
      expect(okello.entry.title, 'Pr. Okello Samuel');
      expect(okello.sermonMatches, 4);
    });

    test('two matching sermons are not enough', () {
      final r = SearchEngine.search([
        entry(SearchKind.presenter, 'Pr. Okello Samuel'),
        entry(SearchKind.sermon, 'Grace One', presenter: 'Pr. Okello Samuel'),
        entry(SearchKind.sermon, 'Grace Two', presenter: 'Pr. Okello Samuel'),
      ], 'grace');
      expect(r.of(SearchKind.presenter), isEmpty);
    });

    test('the tab narrows the hits', () {
      final r = run('daniel', tab: SearchTab.videos);
      expect(r.hits.every((h) => h.entry.kind.tab == SearchTab.videos), isTrue);
      // Prefix matches first; a dated one before an undated one.
      expect(r.hits.map((h) => h.entry.title).toList(), [
        'Daniel and Revelation Seminar',
        'Daniel Playlist',
        'Dare to Be a Daniel',
      ]);
    });

    test('relevance puts exact and prefix matches first', () {
      final titles = run('daniel', tab: SearchTab.sermons)
          .hits
          .map((h) => h.entry.title)
          .toList();
      expect(titles.last, 'Daniel 6'); // Prefix too, but older.
      expect(titles.first, startsWith('Daniel Part'));
    });

    test('newest sorts by date, undated last', () {
      final r = run('daniel',
          tab: SearchTab.videos,
          filters: const SearchFilters(sort: SearchSort.newest));
      expect(r.hits.map((h) => h.entry.title).toList(), [
        'Dare to Be a Daniel',
        'Daniel and Revelation Seminar',
        'Daniel Playlist',
      ]);
    });

    test('date, length and source filters', () {
      expect(
          run('daniel',
                  tab: SearchTab.sermons,
                  filters: const SearchFilters(date: DateFilter.month))
              .hits
              .map((h) => h.entry.id)
              .toSet(),
          {'s1', 's2', 's3'});
      expect(
          run('daniel',
                  tab: SearchTab.sermons,
                  filters: const SearchFilters(length: LengthFilter.under20))
              .hits
              .single
              .entry
              .id,
          'e1');
      expect(
          run('daniel',
                  tab: SearchTab.videos,
                  filters: const SearchFilters(sources: {SearchSources.kids}))
              .hits
              .single
              .entry
              .title,
          'Dare to Be a Daniel');
    });

    test('downloaded only keeps downloaded sermons and episodes', () {
      final r = run('daniel',
          filters: const SearchFilters(downloadedOnly: true),
          downloaded: {'s2', 'e1'});
      expect(r.hits.map((h) => h.entry.id).toSet(), {'s2', 'e1'});
    });

    test('filters that do not apply to a tab are ignored there', () {
      // Presenters have no filters; Live only a source.
      final r = run('okello',
          tab: SearchTab.presenters,
          filters: const SearchFilters(date: DateFilter.week));
      expect(r.hits, hasLength(1));
      expect(
          const SearchFilters(date: DateFilter.week)
              .activeOn(SearchTab.presenters),
          isEmpty);
      expect(filterGroupsFor(SearchTab.live), {FilterGroup.source});
      expect(filterGroupsFor(SearchTab.videos),
          isNot(contains(FilterGroup.downloaded)));
    });

    test('no words on a tab lists everything of that type', () {
      final r = run('', tab: SearchTab.presenters);
      expect(r.hits, hasLength(3));
      expect(run('', tab: SearchTab.videos).hits, hasLength(3));
      expect(run('').isEmpty, isTrue);
    });

    test('nothing matches nothing', () {
      expect(run('kato').isEmpty, isTrue);
      expect(run('kato').counts.values.every((n) => n == 0), isTrue);
    });
  });

  group('top result', () {
    test('an exact entity match wins', () {
      final r = SearchEngine.search([
        entry(SearchKind.series, 'Daniel Speaks Today'),
        entry(SearchKind.podcast, 'Daniel'),
      ], 'daniel');
      expect(r.top?.entry.title, 'Daniel');
    });

    test('a clear prefix match wins', () {
      final r = SearchEngine.search([
        entry(SearchKind.series, 'Daniel Speaks Today'),
        entry(SearchKind.podcast, 'The Book of Daniel'),
      ], 'dan');
      expect(r.top?.entry.title, 'Daniel Speaks Today');
    });

    test('two similar entities means no top result', () {
      final r = SearchEngine.search([
        entry(SearchKind.series, 'Daniel Speaks Today'),
        entry(SearchKind.podcast, 'Daniel Radio'),
      ], 'dan');
      expect(r.top, isNull);
    });

    test('episodes and videos are never the top result', () {
      final r =
          SearchEngine.search([entry(SearchKind.sermon, 'Daniel')], 'daniel');
      expect(r.top, isNull);
    });

    test('filters hide it', () {
      final r = SearchEngine.search(
          [entry(SearchKind.podcast, 'Daniel')], 'daniel',
          filters: const SearchFilters(sort: SearchSort.newest));
      expect(r.top, isNull);
    });
  });

  group('suggestions', () {
    final entries = [
      entry(SearchKind.series, 'Daniel Speaks Today',
          presenter: 'Pr. Okello Samuel'),
      entry(SearchKind.video, 'Daniel and Revelation Seminar',
          source: SearchSources.main),
      entry(SearchKind.sermon, 'Daniel’s Prayer',
          presenter: 'Pr. Wasoga Moses'),
      entry(SearchKind.sermon, 'Daniel Speaks Today', id: 'dup'),
      entry(SearchKind.sermon, 'Grace'),
    ];

    test('wait for two letters', () {
      expect(SearchEngine.suggest(entries, 'd'), isEmpty);
      expect(SearchEngine.suggest(entries, 'da'), isNotEmpty);
    });

    test('start with the query, then bold the typed part of each title', () {
      final rows = SearchEngine.suggest(entries, 'Dani');
      expect(rows.first.isQuery, isTrue);
      expect(rows.first.hit, 'Dani');
      final series = rows[1];
      expect(series.hit, 'Dani');
      expect(series.rest, 'el Speaks Today');
      expect(series.type, 'Series · Pr. Okello Samuel');
    });

    test('repeat titles show once and there are at most six rows', () {
      final many = [
        for (var i = 0; i < 20; i++) entry(SearchKind.sermon, 'Daniel $i'),
      ];
      final rows = SearchEngine.suggest(many, 'dan');
      expect(rows, hasLength(7)); // The query and six suggestions.
      expect(
          SearchEngine.suggest(entries, 'dani')
              .where((r) => r.rest == 'el Speaks Today'),
          hasLength(1));
    });

    test('label what each one is', () {
      expect(SearchEngine.typeLabel(entries[1]), 'Video · Avvento Main');
      expect(SearchEngine.typeLabel(entries[2]), 'Sermon · Pr. Wasoga Moses');
    });
  });

  group('filters', () {
    test('chips list active choices and remove them', () {
      const f = SearchFilters(
          date: DateFilter.year,
          sources: {SearchSources.music, SearchSources.kids},
          downloadedOnly: true);
      final chips = f.chipsOn(SearchTab.sermons);
      expect(chips.map((c) => c.label),
          ['Past year', SearchSources.music, SearchSources.kids, 'Downloaded']);
      var next = f;
      for (final c in chips) {
        next = c.remove(next);
      }
      expect(next.activeOn(SearchTab.all), isEmpty);
    });

    test('Videos hides Downloaded only', () {
      const f = SearchFilters(downloadedOnly: true);
      expect(f.chipsOn(SearchTab.videos), isEmpty);
    });
  });
}
