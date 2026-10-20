import 'list_search_controller.dart';
import 'search_engine.dart';
import 'search_filters.dart';

/// Ranks and filters the items of one list for [ListSearchController]. It
/// works on titles only, so what matches is predictable.
abstract class ListRanker {
  /// 0 when a word of [query] is missing from [title]; otherwise the sum over
  /// the words: 3 when the title starts with it, 2 for a whole word, 1 for a
  /// word starting with it or containing it.
  static int score(String title, String query) {
    final words = SearchEngine.normalize(query)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return 0;
    final normTitle = SearchEngine.normalize(title);
    final titleWords = normTitle.split(' ');

    var total = 0;
    for (final w in words) {
      if (normTitle.startsWith(w)) {
        total += 3;
      } else if (titleWords.contains(w)) {
        total += 2;
      } else if (titleWords.any((t) => t.startsWith(w)) ||
          normTitle.contains(w)) {
        total += 1;
      } else {
        return 0;
      }
    }
    return total;
  }

  /// [items] narrowed by the query and length, then ordered by the sort.
  /// Relevance keeps the page's order for ties (newest first when dated).
  static List<T> apply<T>(
    List<T> items,
    ListSearchController search, {
    required String Function(T) titleOf,
    DateTime? Function(T)? dateOf,
    Duration? Function(T)? durationOf,
  }) {
    final withIndex = <(T, int, int)>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      var rank = 1;
      if (search.hasQuery) {
        rank = score(titleOf(item), search.query);
        if (rank == 0) continue;
      }
      if (search.length != LengthFilter.any) {
        final d = durationOf?.call(item);
        if (d == null || !search.length.accepts(d)) continue;
      }
      withIndex.add((item, i, rank));
    }

    int newer((T, int, int) a, (T, int, int) b) {
      final x = dateOf?.call(a.$1), y = dateOf?.call(b.$1);
      if (x == null || y == null) return 0;
      return y.compareTo(x);
    }

    withIndex.sort((a, b) {
      switch (search.sort) {
        case ListSort.newest:
          final c = newer(a, b);
          return c != 0 ? c : a.$2.compareTo(b.$2);
        case ListSort.oldest:
          final c = newer(b, a);
          return c != 0 ? c : a.$2.compareTo(b.$2);
        case ListSort.relevance:
          // Nothing typed: the page's own order.
          if (!search.hasQuery) return a.$2.compareTo(b.$2);
          final c = b.$3.compareTo(a.$3);
          if (c != 0) return c;
          final n = newer(a, b);
          return n != 0 ? n : a.$2.compareTo(b.$2);
      }
    });
    return [for (final e in withIndex) e.$1];
  }
}
