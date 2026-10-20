import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../search/group_search.dart';
import '../../search/search_models.dart';
import '../../themes/avvento_colors.dart';
import 'search_field.dart';

/// Shared by pages that have no query: nothing to filter.
final ValueListenable<String> noGroupQuery = ValueNotifier<String>('');

/// The search bar at the top of a list. It only filters that list: it
/// writes the (debounced) text to [query], which the list watches.
class GroupSearchField extends StatefulWidget {
  const GroupSearchField({super.key, required this.query, required this.hint});

  final ValueNotifier<String> query;
  final String hint;

  @override
  State<GroupSearchField> createState() => _GroupSearchFieldState();
}

class _GroupSearchFieldState extends State<GroupSearchField> {
  static const _debounce = Duration(milliseconds: 150);

  final _text = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;

  void _onChanged(String text) {
    _timer?.cancel();
    if (text.trim().isEmpty) {
      widget.query.value = '';
      return;
    }
    _timer = Timer(_debounce, () => widget.query.value = text);
  }

  void _cancel() {
    _timer?.cancel();
    _text.clear();
    _focus.unfocus();
    widget.query.value = '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SearchField(
        controller: _text,
        focusNode: _focus,
        hint: widget.hint,
        onChanged: _onChanged,
        onSubmitted: (text) {
          _timer?.cancel();
          widget.query.value = text;
          _focus.unfocus();
        },
        onCancel: _cancel,
      ),
    );
  }
}

/// A sliver that shows [builder] with [items] narrowed to [query], or a
/// short message when none match.
class GroupSearchList<T> extends StatelessWidget {
  const GroupSearchList({
    super.key,
    required this.items,
    required this.query,
    required this.entryOf,
    required this.builder,
  });

  final List<T> items;
  final ValueListenable<String>? query;
  final SearchEntry Function(T) entryOf;
  final Widget Function(BuildContext context, List<T> shown) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: query ?? noGroupQuery,
      builder: (context, q, _) {
        final shown = GroupSearch.filter(items, q, entryOf);
        if (shown.isEmpty && items.isNotEmpty) {
          return SliverToBoxAdapter(child: GroupNoMatches(query: q));
        }
        return builder(context, shown);
      },
    );
  }
}

/// "Nothing for “x” here."
class GroupNoMatches extends StatelessWidget {
  const GroupNoMatches({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 40, 36, 0),
      child: Text(AppConstants.nothingHere(query),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: c.text2,
              fontSize: 14,
              height: 21 / 14,
              fontWeight: FontWeight.w500)),
    );
  }
}
