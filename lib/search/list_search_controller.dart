import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'search_filters.dart';

enum ListSort {
  relevance('Relevance'),
  newest('Newest'),
  oldest('Oldest');

  const ListSort(this.label);
  final String label;
}

/// State of the search inside one list (a channel's playlists, a playlist's
/// videos): whether it's open, the query, sort and length, and the counts
/// the list reports back. Filtering is done by [ListRanker].
class ListSearchController extends ChangeNotifier {
  /// A list needs more items than this to offer search.
  static const minItems = 8;

  bool searching = false;
  String query = '';
  ListSort sort = ListSort.relevance;
  LengthFilter length = LengthFilter.any;

  /// Items in the list, and how many match right now.
  int total = 0;
  int shown = 0;

  /// Whether the list is long enough to be worth searching.
  bool get offersSearch => total > minItems;

  bool get hasQuery => query.trim().isNotEmpty;

  /// Something narrows or reorders the list.
  bool get isRefined =>
      hasQuery || length != LengthFilter.any || sort != ListSort.relevance;

  void open() {
    if (searching) return;
    searching = true;
    notifyListeners();
  }

  /// Back to the plain list: the query and the choices are dropped.
  void close() {
    if (!searching && query.isEmpty) return;
    searching = false;
    query = '';
    sort = ListSort.relevance;
    length = LengthFilter.any;
    notifyListeners();
  }

  void setQuery(String value) {
    if (value == query) return;
    query = value;
    notifyListeners();
  }

  void setSort(ListSort value) {
    if (value == sort) return;
    sort = value;
    notifyListeners();
  }

  void setLength(LengthFilter value) {
    if (value == length) return;
    length = value;
    notifyListeners();
  }

  /// Called by the list as it builds. Applied after the frame, so it can
  /// rebuild the count without changing state mid-build.
  void report({required int total, required int shown}) {
    if (total == this.total && shown == this.shown) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      this.total = total;
      this.shown = shown;
      notifyListeners();
    });
  }
}
