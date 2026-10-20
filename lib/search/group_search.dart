import 'search_engine.dart';
import 'search_models.dart';

/// Search inside one list (a channel's playlists, a playlist's videos, the
/// live channels): the same ranking as Search, applied to what the page
/// already has.
abstract class GroupSearch {
  /// [items] that match [query], best first (ties keep their order); all of
  /// them for an empty query.
  static List<T> filter<T>(
      List<T> items, String query, SearchEntry Function(T) entryOf) {
    if (SearchEngine.normalize(query).isEmpty) return items;
    final scored = <(int, int, T)>[];
    for (var i = 0; i < items.length; i++) {
      final s = SearchEngine.score(entryOf(items[i]), query);
      if (s > 0) scored.add((s, i, items[i]));
    }
    scored.sort((a, b) {
      final c = b.$1.compareTo(a.$1);
      return c != 0 ? c : a.$2.compareTo(b.$2);
    });
    return [for (final s in scored) s.$3];
  }
}
