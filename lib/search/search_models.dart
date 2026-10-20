import 'search_engine.dart';

/// What a search result is.
enum SearchKind {
  presenter,
  series,
  podcast,
  sermon,
  episode,
  video,
  playlist,
  live,
}

/// The type tabs under the search field.
enum SearchTab {
  all('All'),
  presenters('Presenters'),
  podcasts('Podcasts'),
  sermons('Sermons'),
  videos('Videos'),
  live('Live');

  const SearchTab(this.label);

  final String label;
}

extension SearchKindTab on SearchKind {
  /// The tab a result of this kind belongs to.
  SearchTab get tab => switch (this) {
        SearchKind.presenter => SearchTab.presenters,
        SearchKind.series || SearchKind.podcast => SearchTab.podcasts,
        SearchKind.sermon || SearchKind.episode => SearchTab.sermons,
        SearchKind.video || SearchKind.playlist => SearchTab.videos,
        SearchKind.live => SearchTab.live,
      };

  /// Presenters, series and podcasts can be the "Top result".
  bool get isEntity =>
      this == SearchKind.presenter ||
      this == SearchKind.series ||
      this == SearchKind.podcast;
}

/// Where content comes from; the filter sheet's Source group.
abstract class SearchSources {
  static const radio = 'Avvento Radio';
  static const main = 'Avvento Main';
  static const music = 'Avvento Music';
  static const kids = 'Avvento Kids';
  static const all = [radio, main, music, kids];
}

/// One searchable thing. [payload] is the model it came from, so the page
/// can open it.
class SearchEntry {
  SearchEntry({
    required this.kind,
    required this.id,
    required this.title,
    required this.payload,
    this.subtitle = '',
    this.presenter = '',
    this.source = '',
    this.publishedAt,
    this.duration,
    this.cover = '',
    this.badge,
    this.keywords = '',
    this.count = 0,
  });

  final SearchKind kind;
  final String id;
  final String title;
  final String subtitle;

  /// Who preaches it; links sermons to their presenter.
  final String presenter;

  /// One of [SearchSources], or empty.
  final String source;
  final DateTime? publishedAt;
  final Duration? duration;
  final String cover;

  /// What shows on the corner of its picture: a video's length, or "Live".
  final String? badge;

  /// Extra words that should find it.
  final String keywords;

  /// Sermons, parts or videos it holds.
  final int count;
  final Object payload;

  // Normalized once: a search runs over thousands of these per keystroke.
  late final String normTitle = SearchEngine.normalize(title);
  late final String normTitleBare = kind == SearchKind.presenter
      ? SearchEngine.withoutTitle(title)
      : normTitle;
  late final String normPeople = SearchEngine.normalize('$presenter $subtitle');
  late final String normKeywords =
      SearchEngine.normalize('$keywords $presenter');
}
