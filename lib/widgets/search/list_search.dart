import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../controller/search_index_controller.dart';
import '../../search/group_search.dart';
import '../../search/list_search_controller.dart';
import '../../search/search_filters.dart';
import '../../themes/avvento_colors.dart';
import 'search_field.dart';

/// What a page needs to run the search inside its list: the state, the
/// scroll position to come back to, and the text field's controllers.
class ListSearchHandle {
  ListSearchHandle()
      : controller = ListSearchController(),
        scroll = ScrollController(),
        text = TextEditingController(),
        focus = FocusNode();

  final ListSearchController controller;
  final ScrollController scroll;
  final TextEditingController text;
  final FocusNode focus;

  double _offset = 0;
  Timer? _debounce;

  /// Typing narrows the list after this pause.
  static const typingPause = Duration(milliseconds: 120);

  /// Opens the field. The header is swapped for it, so the list starts
  /// right under the bar; where you were is remembered.
  void open() {
    if (controller.searching) return;
    _offset = scroll.hasClients ? scroll.offset : 0;
    controller.open();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(0);
      focus.requestFocus();
    });
  }

  /// Back to the plain list, where it was.
  void close() {
    _debounce?.cancel();
    text.clear();
    focus.unfocus();
    controller.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.jumpTo(_offset.clamp(0, scroll.position.maxScrollExtent));
      }
    });
  }

  void onTyped(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      controller.setQuery('');
      return;
    }
    _debounce = Timer(typingPause, () => controller.setQuery(value.trim()));
  }

  void clearText() {
    _debounce?.cancel();
    text.clear();
    controller.setQuery('');
  }

  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    scroll.dispose();
    text.dispose();
    focus.dispose();
  }
}

/// Owns a [ListSearchHandle] for a page and rebuilds it as the search
/// changes.
class ListSearchScope extends StatefulWidget {
  const ListSearchScope({super.key, required this.builder});

  final Widget Function(BuildContext context, ListSearchHandle search) builder;

  @override
  State<ListSearchScope> createState() => _ListSearchScopeState();
}

class _ListSearchScopeState extends State<ListSearchScope> {
  final _handle = ListSearchHandle();

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _handle.controller,
        builder: (context, _) => widget.builder(context, _handle),
      );
}

/// The magnifier for a page's app bar; there only when the list is long
/// enough and the search isn't open.
class ListSearchButton extends StatelessWidget {
  const ListSearchButton({super.key, required this.search});

  final ListSearchHandle search;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final controller = search.controller;
    if (!controller.offersSearch || controller.searching) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: AppConstants.search,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: Icon(Icons.search_rounded, size: 22, color: c.text),
      onPressed: search.open,
    );
  }
}

/// The two pinned slivers shown while searching: the field, then the count
/// with Sort (and Length, for videos).
List<Widget> listSearchTop(
  BuildContext context,
  ListSearchHandle search, {
  required String hint,
  required String unit,
  bool showLength = false,
}) {
  final c = Theme.of(context).avvento;
  final top = MediaQuery.paddingOf(context).top;
  return [
    SliverPersistentHeader(
      pinned: true,
      delegate: _FixedHeader(
        height: top + 60,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.only(top: top),
          child: SearchField(
            controller: search.text,
            focusNode: search.focus,
            hint: hint,
            autofocus: true,
            onChanged: search.onTyped,
            onSubmitted: (_) => search.focus.unfocus(),
            onCancel: search.close,
          ),
        ),
      ),
    ),
    SliverPersistentHeader(
      pinned: true,
      delegate: _FixedHeader(
        height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: c.line)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              _ControlRow(search: search, unit: unit, showLength: showLength),
        ),
      ),
    ),
  ];
}

class _FixedHeader extends SliverPersistentHeaderDelegate {
  const _FixedHeader({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox(height: height, child: child);

  @override
  bool shouldRebuild(_FixedHeader old) => true;
}

class _ControlRow extends StatelessWidget {
  const _ControlRow(
      {required this.search, required this.unit, required this.showLength});

  final ListSearchHandle search;
  final String unit;
  final bool showLength;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final s = search.controller;
    final count = s.isRefined && s.hasQuery || s.length != LengthFilter.any
        ? '${s.shown} of ${s.total}'
        : '${s.total} $unit';

    return Row(
      children: [
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(count,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: c.text2,
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ),
        ),
        // The chips scroll sideways rather than overflow at large text sizes.
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(children: [
              _Menu<ListSort>(
                label: s.sort.label,
                tooltip: '${AppConstants.sortBy}: ${s.sort.label}',
                values: ListSort.values,
                selected: s.sort,
                labelOf: (v) => v.label,
                onSelected: s.setSort,
              ),
              if (showLength) ...[
                const SizedBox(width: 8),
                s.length == LengthFilter.any
                    ? _Menu<LengthFilter>(
                        label: AppConstants.length,
                        tooltip: AppConstants.length,
                        values: LengthFilter.values,
                        selected: s.length,
                        labelOf: (v) => v.label,
                        onSelected: s.setLength,
                      )
                    : _SetLength(
                        label: s.length.label,
                        onClear: () => s.setLength(LengthFilter.any)),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

/// A 32dp chip inside a 44dp target that opens a small menu.
class _Menu<T> extends StatelessWidget {
  const _Menu({
    required this.label,
    required this.tooltip,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final String tooltip;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 2),
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 180),
      menuPadding: const EdgeInsets.all(6),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.line),
      ),
      itemBuilder: (_) => [
        for (final v in values)
          PopupMenuItem<T>(
            value: v,
            height: 44,
            padding: EdgeInsets.zero,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: v == selected ? c.surface2 : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(labelOf(v),
                        style: TextStyle(
                            color: c.text,
                            fontSize: 14,
                            height: 18 / 14,
                            fontWeight: FontWeight.w600)),
                  ),
                  if (v == selected)
                    Icon(Icons.check_rounded, size: 16, color: c.accentText),
                ],
              ),
            ),
          ),
      ],
      child: SizedBox(
        height: 44,
        child: Center(
          child: Container(
            height: 32,
            padding: const EdgeInsets.only(left: 12, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                        color: c.text,
                        fontSize: 13,
                        height: 1,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 14, color: c.text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A length that's set: its value and a × that clears it.
class _SetLength extends StatelessWidget {
  const _SetLength({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Semantics(
      button: true,
      label: AppConstants.removeFilter(label),
      excludeSemantics: true,
      child: InkWell(
        onTap: onClear,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Container(
              height: 32,
              padding: const EdgeInsets.only(left: 12, right: 8),
              decoration: BoxDecoration(
                  color: c.accentSoft, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: c.text,
                          fontSize: 13,
                          height: 1,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Icon(Icons.close_rounded, size: 12, color: c.text2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The list itself, narrowed and ordered by the search. [itemBuilder] gets the
/// words to mark in each title. Nothing changes while the search is closed.
class ListSearchList<T> extends StatelessWidget {
  const ListSearchList({
    super.key,
    required this.items,
    required this.search,
    required this.titleOf,
    required this.itemBuilder,
    this.dateOf,
    this.durationOf,
  });

  final List<T> items;
  final ListSearchHandle search;
  final String Function(T) titleOf;
  final DateTime? Function(T)? dateOf;
  final Duration? Function(T)? durationOf;
  final Widget Function(BuildContext context, T item, String query) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final controller = search.controller;
    final active = controller.searching;
    final shown = active
        ? ListRanker.apply(items, controller,
            titleOf: titleOf, dateOf: dateOf, durationOf: durationOf)
        : items;
    controller.report(total: items.length, shown: shown.length);

    if (active && shown.isEmpty && items.isNotEmpty) {
      return SliverToBoxAdapter(
        child: ListSearchEmpty(
          query: controller.query,
          onClear: search.clearText,
        ),
      );
    }
    final query = active ? controller.query : '';
    return SliverList.builder(
      itemCount: shown.length,
      itemBuilder: (context, i) => itemBuilder(context, shown[i], query),
    );
  }
}

/// "Nothing for 'kato' in this list", with a way out: clear the search, or
/// try all of Avvento.
class ListSearchEmpty extends StatelessWidget {
  const ListSearchEmpty(
      {super.key, required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 64, 36, 0),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration:
                BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
            child: Icon(Icons.search_rounded, size: 30, color: c.accentText),
          ),
          const SizedBox(height: 18),
          Text(AppConstants.nothingHere(query),
              textAlign: TextAlign.center,
              style: TextStyle(color: c.text2, fontSize: 15, height: 22 / 15)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(44, 48),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              foregroundColor: c.text,
              side:
                  BorderSide(color: c.text3.withValues(alpha: 0.5), width: 1.5),
              shape: const StadiumBorder(),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: const Text(AppConstants.clearSearchButton),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Get.find<SearchIndexController>().searchAll(query),
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              foregroundColor: c.accentText,
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            child: const Text(AppConstants.searchAllOfAvvento),
          ),
        ],
      ),
    );
  }
}
