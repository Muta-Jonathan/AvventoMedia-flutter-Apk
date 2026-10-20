import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../search/search_filters.dart';
import '../../search/search_models.dart';
import '../../themes/avvento_colors.dart';
import '../../themes/avvento_theme.dart';

/// Opens the filter sheet for [tab]. [onChanged] runs on every choice so the
/// results behind it follow; [countFor] says how many results [Show] would
/// give with a set of filters.
Future<void> showSearchFilterSheet(
  BuildContext context, {
  required SearchTab tab,
  required SearchFilters filters,
  required ValueChanged<SearchFilters> onChanged,
  required int Function(SearchFilters) countFor,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => AvventoThemeScope(
      child: _FilterSheet(
          tab: tab, initial: filters, onChanged: onChanged, countFor: countFor),
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.tab,
    required this.initial,
    required this.onChanged,
    required this.countFor,
  });

  final SearchTab tab;
  final SearchFilters initial;
  final ValueChanged<SearchFilters> onChanged;
  final int Function(SearchFilters) countFor;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late SearchFilters _filters = widget.initial;

  void _set(SearchFilters next) {
    setState(() => _filters = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final groups = filterGroupsFor(widget.tab);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Material(
      color: c.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                child: Column(
                  children: [
                    Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                            color: c.text3.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(3))),
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(AppConstants.filters,
                                style: TextStyle(
                                    fontFamily: AvventoTheme.newsreader,
                                    color: c.text,
                                    fontSize: 22,
                                    height: 28 / 22,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _set(SearchFilters.none),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            foregroundColor: c.text2,
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          child: const Text(AppConstants.reset),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (groups.contains(FilterGroup.date))
                        _Group(
                          title: 'Date',
                          options: [
                            for (final d in DateFilter.values)
                              _Option(d.label, _filters.date == d,
                                  () => _set(_filters.copyWith(date: d))),
                          ],
                        ),
                      if (groups.contains(FilterGroup.length))
                        _Group(
                          title: 'Length',
                          options: [
                            for (final l in LengthFilter.values)
                              _Option(l.label, _filters.length == l,
                                  () => _set(_filters.copyWith(length: l))),
                          ],
                        ),
                      if (groups.contains(FilterGroup.source))
                        _Group(
                          title: 'Source',
                          options: [
                            for (final s in SearchSources.all)
                              _Option(s, _filters.sources.contains(s), () {
                                final next = {..._filters.sources};
                                next.contains(s) ? next.remove(s) : next.add(s);
                                _set(_filters.copyWith(sources: next));
                              }),
                          ],
                        ),
                      if (groups.contains(FilterGroup.sort))
                        _Group(
                          title: 'Sort',
                          options: [
                            for (final s in SearchSort.values)
                              _Option(s.label, _filters.sort == s,
                                  () => _set(_filters.copyWith(sort: s))),
                          ],
                        ),
                      if (groups.contains(FilterGroup.downloaded)) ...[
                        const SizedBox(height: 12),
                        Divider(height: 1, color: c.line),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(AppConstants.downloadedOnly,
                              style: TextStyle(
                                  color: c.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          value: _filters.downloadedOnly,
                          activeThumbColor: c.onAccent,
                          activeTrackColor: c.accent,
                          onChanged: (v) =>
                              _set(_filters.copyWith(downloadedOnly: v)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.line))),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.accent,
                      foregroundColor: c.onAccent,
                      minimumSize: const Size(44, 48),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: Text(
                        AppConstants.showResults(widget.countFor(_filters))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option {
  const _Option(this.label, this.selected, this.onTap);

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.options});

  final String title;
  final List<_Option> options;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Semantics(
            header: true,
            child: Text(title,
                style: TextStyle(
                    color: c.text2,
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final o in options)
              Semantics(
                button: true,
                selected: o.selected,
                label: o.label,
                excludeSemantics: true,
                child: InkWell(
                  onTap: o.onTap,
                  borderRadius: BorderRadius.circular(22),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Center(
                      widthFactor: 1,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: o.selected ? c.text : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: o.selected ? c.text : c.line),
                        ),
                        child: Text(o.label,
                            style: TextStyle(
                                color: o.selected ? c.bg : c.text,
                                fontSize: 13,
                                height: 1,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
