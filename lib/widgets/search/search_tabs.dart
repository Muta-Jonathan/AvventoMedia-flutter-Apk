import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../search/search_filters.dart';
import '../../search/search_models.dart';
import '../../themes/avvento_colors.dart';

/// The filter button, then All / Presenters / Podcasts / Sermons / Videos /
/// Live with their counts.
class SearchTabsBar extends StatelessWidget {
  const SearchTabsBar({
    super.key,
    required this.tab,
    required this.counts,
    required this.activeFilters,
    required this.filtersEnabled,
    required this.onTab,
    required this.onFilters,
  });

  final SearchTab tab;
  final Map<SearchTab, int> counts;
  final int activeFilters;
  final bool filtersEnabled;
  final ValueChanged<SearchTab> onTab;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final active = activeFilters > 0;
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: Row(
        children: [
          Semantics(
            button: true,
            enabled: filtersEnabled,
            label: AppConstants.filtersCount(activeFilters),
            excludeSemantics: true,
            child: InkWell(
              onTap: filtersEnabled ? onFilters : null,
              borderRadius: BorderRadius.circular(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                child: Center(
                  child: Opacity(
                    opacity: filtersEnabled ? 1 : 0.4,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: active ? c.accentSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: active ? c.accent : c.line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune_rounded, size: 16, color: c.text),
                          if (active) ...[
                            const SizedBox(width: 6),
                            Container(
                              constraints: const BoxConstraints(minWidth: 18),
                              height: 18,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: c.accent,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Text('$activeFilters',
                                  style: TextStyle(
                                      color: c.onAccent,
                                      fontSize: 11,
                                      height: 1,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 22, color: c.line),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  for (final t in SearchTab.values) ...[
                    if (t != SearchTab.all) const SizedBox(width: 8),
                    _TabChip(
                      tab: t,
                      count: counts[t] ?? 0,
                      selected: t == tab,
                      onTap: () => onTab(t),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.tab,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final SearchTab tab;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final fg = selected ? c.bg : c.text;
    final showCount = tab != SearchTab.all && count > 0;
    return Semantics(
      button: true,
      selected: selected,
      label: showCount ? '${tab.label}, $count' : tab.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Center(
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? c.text : Colors.transparent,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: selected ? c.text : c.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tab.label,
                      style: TextStyle(
                          color: fg,
                          fontSize: 13,
                          height: 1,
                          fontWeight: FontWeight.w600)),
                  if (showCount) ...[
                    const SizedBox(width: 6),
                    Text('$count',
                        style: TextStyle(
                            color: selected ? c.bg : c.text3,
                            fontSize: 12,
                            height: 1,
                            fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Removable chips for the filters that are on.
class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips(
      {super.key, required this.chips, required this.onRemove});

  final List<ActiveFilter> chips;
  final ValueChanged<ActiveFilter> onRemove;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
      child: Wrap(
        spacing: 8,
        children: [
          for (final chip in chips)
            Semantics(
              button: true,
              label: AppConstants.removeFilter(chip.label),
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onRemove(chip),
                borderRadius: BorderRadius.circular(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      decoration: BoxDecoration(
                          color: c.accentSoft,
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(chip.label,
                              style: TextStyle(
                                  color: c.text,
                                  fontSize: 12,
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
            ),
        ],
      ),
    );
  }
}
