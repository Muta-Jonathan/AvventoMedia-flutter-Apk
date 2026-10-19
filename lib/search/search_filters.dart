import 'search_models.dart';

enum DateFilter {
  any('Any time'),
  week('Past week'),
  month('Past month'),
  year('Past year');

  const DateFilter(this.label);
  final String label;

  Duration? get span => switch (this) {
        DateFilter.any => null,
        DateFilter.week => const Duration(days: 7),
        DateFilter.month => const Duration(days: 30),
        DateFilter.year => const Duration(days: 365),
      };
}

enum LengthFilter {
  any('Any'),
  under20('Under 20 min'),
  mid('20–60 min'),
  over60('Over 60 min');

  const LengthFilter(this.label);
  final String label;

  bool accepts(Duration d) => switch (this) {
        LengthFilter.any => true,
        LengthFilter.under20 => d < const Duration(minutes: 20),
        LengthFilter.mid =>
          d >= const Duration(minutes: 20) && d <= const Duration(minutes: 60),
        LengthFilter.over60 => d > const Duration(minutes: 60),
      };
}

enum SearchSort {
  relevance('Relevance'),
  newest('Newest');

  const SearchSort(this.label);
  final String label;
}

enum FilterGroup { date, length, source, sort, downloaded }

/// The groups the filter sheet offers on [tab]. Presenters have none, Live
/// only a source, and Videos can't be downloaded.
Set<FilterGroup> filterGroupsFor(SearchTab tab) => switch (tab) {
      SearchTab.all || SearchTab.sermons => FilterGroup.values.toSet(),
      SearchTab.presenters => {},
      SearchTab.podcasts => {FilterGroup.date, FilterGroup.sort},
      SearchTab.videos => {
          FilterGroup.date,
          FilterGroup.length,
          FilterGroup.source,
          FilterGroup.sort,
        },
      SearchTab.live => {FilterGroup.source},
    };

/// What the filter sheet has set. Immutable.
class SearchFilters {
  const SearchFilters({
    this.date = DateFilter.any,
    this.length = LengthFilter.any,
    this.sources = const {},
    this.sort = SearchSort.relevance,
    this.downloadedOnly = false,
  });

  final DateFilter date;
  final LengthFilter length;
  final Set<String> sources;
  final SearchSort sort;
  final bool downloadedOnly;

  static const none = SearchFilters();

  SearchFilters copyWith({
    DateFilter? date,
    LengthFilter? length,
    Set<String>? sources,
    SearchSort? sort,
    bool? downloadedOnly,
  }) =>
      SearchFilters(
        date: date ?? this.date,
        length: length ?? this.length,
        sources: sources ?? this.sources,
        sort: sort ?? this.sort,
        downloadedOnly: downloadedOnly ?? this.downloadedOnly,
      );

  /// The groups that differ from their default, among those on [tab].
  Set<FilterGroup> activeOn(SearchTab tab) {
    final groups = filterGroupsFor(tab);
    return {
      if (date != DateFilter.any) FilterGroup.date,
      if (length != LengthFilter.any) FilterGroup.length,
      if (sources.isNotEmpty) FilterGroup.source,
      if (sort != SearchSort.relevance) FilterGroup.sort,
      if (downloadedOnly) FilterGroup.downloaded,
    }.intersection(groups);
  }

  /// One removable chip per active choice on [tab].
  List<ActiveFilter> chipsOn(SearchTab tab) {
    final active = activeOn(tab);
    return [
      if (active.contains(FilterGroup.date))
        ActiveFilter(date.label, (f) => f.copyWith(date: DateFilter.any)),
      if (active.contains(FilterGroup.length))
        ActiveFilter(length.label, (f) => f.copyWith(length: LengthFilter.any)),
      if (active.contains(FilterGroup.source))
        for (final s in sources)
          ActiveFilter(
              s, (f) => f.copyWith(sources: {...f.sources}..remove(s))),
      if (active.contains(FilterGroup.sort))
        ActiveFilter(sort.label, (f) => f.copyWith(sort: SearchSort.relevance)),
      if (active.contains(FilterGroup.downloaded))
        ActiveFilter('Downloaded', (f) => f.copyWith(downloadedOnly: false)),
    ];
  }
}

/// A chip on the results screen and how to take it off.
class ActiveFilter {
  const ActiveFilter(this.label, this.remove);

  final String label;
  final SearchFilters Function(SearchFilters) remove;
}
