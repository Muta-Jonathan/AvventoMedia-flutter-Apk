import 'search_filters.dart';
import 'search_models.dart';

/// A matching entry and how well it matches.
class SearchHit {
  const SearchHit(this.entry, this.score, {this.sermonMatches = 0});

  final SearchEntry entry;
  final int score;

  /// For a presenter: how many of their sermons match the query.
  final int sermonMatches;
}

class SearchResults {
  const SearchResults({
    required this.query,
    required this.hits,
    required this.counts,
    this.top,
  });

  final String query;

  /// Matches on the chosen tab, in display order.
  final List<SearchHit> hits;

  /// Matches per tab, for the tab labels.
  final Map<SearchTab, int> counts;

  /// The one entity that clearly wins, on the All tab.
  final SearchHit? top;

  bool get isEmpty => hits.isEmpty;

  List<SearchHit> of(SearchKind kind) => [
        for (final h in hits)
          if (h.entry.kind == kind) h
      ];
}

/// A row in the suggestions list.
class Suggestion {
  const Suggestion({
    required this.hit,
    required this.rest,
    this.type = '',
    this.entry,
  });

  /// The typed part of the title (bold) and the rest.
  final String hit;
  final String rest;
  final String type;

  /// Null for the first row: the plain query.
  final SearchEntry? entry;

  bool get isQuery => entry == null;
}

/// Ranks and filters [SearchEntry]s. No state, no Flutter.
class SearchEngine {
  static const _titles = ['pr', 'ev', 'dr', 'bro', 'sis', 'elder', 'pastor'];
  static final _titlePrefix =
      RegExp('^(${_titles.join('|')})\\.?\\s+', caseSensitive: false);

  /// Letters typed before suggestions appear.
  static const minQuery = 2;

  /// Lower case, one space between words, accents and punctuation gone.
  static String normalize(String s) {
    const from = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñç';
    const to = 'aaaaaaeeeeiiiiooooouuuuyync';
    final buffer = StringBuffer();
    for (final rune in s.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      final i = from.indexOf(ch);
      buffer.write(i >= 0 ? to[i] : ch);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r"[’'`]"), '')
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// "Pr. Okello Samuel" → "okello samuel".
  static String withoutTitle(String name) =>
      normalize(name.replaceFirst(_titlePrefix, ''));

  /// 0 for no match; exact 100, prefix 85, a word starts with it 70,
  /// contains 55, every word found 45, only in the keywords 30.
  static int score(SearchEntry e, String query) {
    final q = normalize(query);
    if (q.isEmpty) return 0;
    final names = {e.normTitle, e.normTitleBare};

    var best = 0;
    for (final name in names) {
      if (name == q) return 100;
      if (name.startsWith(q)) {
        best = best < 85 ? 85 : best;
      } else if (name.split(' ').any((w) => w.startsWith(q))) {
        best = best < 70 ? 70 : best;
      } else if (name.contains(q)) {
        best = best < 55 ? 55 : best;
      }
    }
    if (best > 0) return best;

    final tokens = q.split(' ');
    final haystack = '${names.join(' ')} ${e.normPeople}';
    if (tokens.length > 1 && tokens.every(haystack.contains)) return 45;
    if (e.normKeywords.contains(q)) return 30;
    return 0;
  }

  static bool _passes(SearchEntry e, SearchFilters f, SearchTab tab,
      DateTime now, bool Function(String id) isDownloaded) {
    final groups = filterGroupsFor(tab);
    if (groups.contains(FilterGroup.date) && f.date != DateFilter.any) {
      final at = e.publishedAt;
      if (at == null || now.difference(at) > f.date.span!) return false;
    }
    if (groups.contains(FilterGroup.length) && f.length != LengthFilter.any) {
      final d = e.duration;
      if (d == null || !f.length.accepts(d)) return false;
    }
    if (groups.contains(FilterGroup.source) && f.sources.isNotEmpty) {
      if (!f.sources.contains(e.source)) return false;
    }
    if (groups.contains(FilterGroup.downloaded) && f.downloadedOnly) {
      final audio = e.kind == SearchKind.sermon || e.kind == SearchKind.episode;
      if (!audio || !isDownloaded(e.id)) return false;
    }
    return true;
  }

  /// Everything matching [query] that passes [filters], on [tab].
  static SearchResults search(
    List<SearchEntry> entries,
    String query, {
    SearchTab tab = SearchTab.all,
    SearchFilters filters = SearchFilters.none,
    DateTime? now,
    bool Function(String id)? isDownloaded,
  }) {
    final clock = now ?? DateTime.now();
    // No words on a tab means "browse": everything of that type.
    final browse = normalize(query).isEmpty;
    int scoreOf(SearchEntry e, SearchTab t) =>
        browse ? (t == SearchTab.all ? 0 : 1) : score(e, query);
    final downloaded = isDownloaded ?? (_) => false;

    // Per tab, because the filters that apply differ by tab.
    List<SearchHit> matchesFor(SearchTab t) {
      final hits = <SearchHit>[];
      for (final e in entries) {
        if (t != SearchTab.all && e.kind.tab != t) continue;
        final s = scoreOf(e, t);
        if (s > 0 && _passes(e, filters, t, clock, downloaded)) {
          hits.add(SearchHit(e, s));
        }
      }
      return hits;
    }

    final all = _withPresenterSermons(entries, matchesFor(SearchTab.all));
    // Presenters have no filters, so none of them apply to that tab.
    final presenters = [
      for (final h in _withPresenterSermons(entries, [
        for (final e in entries)
          if (scoreOf(e, SearchTab.presenters) > 0)
            SearchHit(e, scoreOf(e, SearchTab.presenters))
      ]))
        if (h.entry.kind == SearchKind.presenter) h
    ];
    final counts = <SearchTab, int>{};
    for (final t in SearchTab.values) {
      if (t == SearchTab.all) continue;
      counts[t] =
          t == SearchTab.presenters ? presenters.length : matchesFor(t).length;
    }

    final shown = switch (tab) {
      SearchTab.all => all,
      SearchTab.presenters => presenters,
      _ => matchesFor(tab),
    };
    final ordered = _order(shown, filters.sort);

    return SearchResults(
      query: query,
      hits: ordered,
      counts: counts,
      top: tab == SearchTab.all && filters.activeOn(tab).isEmpty
          ? _top(all)
          : null,
    );
  }

  /// A presenter also matches when several of their sermons do.
  static List<SearchHit> _withPresenterSermons(
      List<SearchEntry> entries, List<SearchHit> hits) {
    final perPresenter = <String, int>{};
    for (final h in hits) {
      if (h.entry.kind == SearchKind.sermon && h.entry.presenter.isNotEmpty) {
        perPresenter.update(h.entry.presenter, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    final named = {
      for (final h in hits)
        if (h.entry.kind == SearchKind.presenter) h.entry.title
    };
    final out = <SearchHit>[];
    for (final h in hits) {
      if (h.entry.kind == SearchKind.presenter) {
        out.add(SearchHit(h.entry, h.score,
            sermonMatches: perPresenter[h.entry.title] ?? 0));
      } else {
        out.add(h);
      }
    }
    for (final e in entries) {
      if (e.kind != SearchKind.presenter || named.contains(e.title)) continue;
      final n = perPresenter[e.title] ?? 0;
      if (n >= 3) out.add(SearchHit(e, 45, sermonMatches: n));
    }
    return out;
  }

  static List<SearchHit> _order(List<SearchHit> hits, SearchSort sort) {
    final list = List.of(hits);
    int newer(SearchHit a, SearchHit b) {
      final x = a.entry.publishedAt, y = b.entry.publishedAt;
      if (x == null && y == null) return 0;
      if (x == null) return 1;
      if (y == null) return -1;
      return y.compareTo(x);
    }

    list.sort((a, b) {
      if (sort == SearchSort.newest) {
        final c = newer(a, b);
        return c != 0 ? c : b.score.compareTo(a.score);
      }
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      // A channel on air before one that isn't.
      final onAir =
          (b.entry.live == true ? 1 : 0) - (a.entry.live == true ? 1 : 0);
      if (onAir != 0) return onAir;
      final n = newer(a, b);
      return n != 0 ? n : a.entry.title.length.compareTo(b.entry.title.length);
    });
    return list;
  }

  /// The best presenter, series or podcast, when it clearly wins: an exact
  /// match, or a prefix match well ahead of the next entity.
  static SearchHit? _top(List<SearchHit> hits) {
    final entities = _order([
      for (final h in hits)
        if (h.entry.kind.isEntity) h
    ], SearchSort.relevance);
    if (entities.isEmpty) return null;
    final best = entities.first;
    if (best.score >= 100) return best;
    if (best.score < 85) return null;
    final next = entities.length > 1 ? entities[1].score : 0;
    return best.score - next >= 10 ? best : null;
  }

  /// Up to [limit] rows for what has been typed so far: the plain query,
  /// then the best matches of any kind. Nothing under [minQuery] letters.
  static List<Suggestion> suggest(List<SearchEntry> entries, String query,
      {int limit = 6}) {
    final q = query.trim();
    if (normalize(q).length < minQuery) return const [];
    final scored = <SearchHit>[
      for (final e in entries)
        if (score(e, q) > 0) SearchHit(e, score(e, q))
    ];
    scored.sort((a, b) {
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      // Entities before their episodes.
      final k =
          (b.entry.kind.isEntity ? 1 : 0) - (a.entry.kind.isEntity ? 1 : 0);
      return k != 0 ? k : a.entry.title.length.compareTo(b.entry.title.length);
    });

    final seen = <String>{};
    final rows = <Suggestion>[Suggestion(hit: q, rest: '')];
    for (final h in scored) {
      if (rows.length > limit) break;
      final key = normalize(h.entry.title);
      if (!seen.add(key)) continue;
      final title = h.entry.title;
      final starts = title.toLowerCase().startsWith(q.toLowerCase());
      rows.add(Suggestion(
        hit: starts ? title.substring(0, q.length) : '',
        rest: starts ? title.substring(q.length) : title,
        type: typeLabel(h.entry),
        entry: h.entry,
      ));
    }
    return rows;
  }

  /// "Series · Pr. Okello Samuel".
  static String typeLabel(SearchEntry e) {
    final detail = switch (e.kind) {
      SearchKind.live => e.live == false ? 'Off air' : '',
      SearchKind.series || SearchKind.sermon => e.presenter,
      SearchKind.video || SearchKind.playlist => e.source,
      SearchKind.presenter => e.count > 0 ? '${e.count} sermons' : '',
      _ => '',
    };
    final name = switch (e.kind) {
      SearchKind.presenter => 'Presenter',
      SearchKind.series => 'Series',
      SearchKind.podcast => 'Podcast',
      SearchKind.sermon => 'Sermon',
      SearchKind.episode => 'Episode',
      SearchKind.video => 'Video',
      SearchKind.playlist => 'Playlist',
      SearchKind.live => 'Live',
    };
    return detail.isEmpty ? name : '$name · $detail';
  }
}
