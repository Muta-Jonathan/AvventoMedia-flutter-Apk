import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../search/search_engine.dart';
import '../../search/search_models.dart';
import '../../themes/avvento_colors.dart';
import '../../themes/avvento_theme.dart';
import '../listen/section_header.dart';

/// What the Browse tiles open.
class BrowseTile {
  const BrowseTile(this.label, this.icon, this.tab, {this.query = ''});

  final String label;
  final IconData icon;
  final SearchTab tab;
  final String query;

  static const all = [
    BrowseTile(
        'Presenters', Icons.person_outline_rounded, SearchTab.presenters),
    BrowseTile('Podcasts', Icons.podcasts_rounded, SearchTab.podcasts),
    BrowseTile('Sermons', Icons.menu_book_outlined, SearchTab.sermons),
    BrowseTile('Videos', Icons.ondemand_video_rounded, SearchTab.videos),
    BrowseTile(
        AppConstants.bible, Icons.auto_stories_outlined, SearchTab.podcasts,
        query: 'bible'),
    BrowseTile('Live', Icons.sensors_rounded, SearchTab.live),
  ];
}

/// Before anything is typed: the title, Recent searches and Browse tiles.
class SearchStart extends StatelessWidget {
  const SearchStart({
    super.key,
    required this.recent,
    required this.onRecent,
    required this.onRemoveRecent,
    required this.onClearRecent,
    required this.onBrowse,
  });

  final List<String> recent;
  final ValueChanged<String> onRecent;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;
  final ValueChanged<BrowseTile> onBrowse;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recent.isNotEmpty) ...[
          ListenSectionHeader(
            title: AppConstants.recent,
            action: AppConstants.clear,
            onAction: onClearRecent,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 2),
          ),
          for (final term in recent)
            _RecentRow(
                term: term,
                onTap: () => onRecent(term),
                onRemove: () => onRemoveRecent(term)),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Semantics(
            header: true,
            child: Text(AppConstants.browse,
                style: TextStyle(
                    color: c.text,
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final tile in BrowseTile.all)
                  SizedBox(
                    width: width,
                    child: Semantics(
                      button: true,
                      label: tile.label,
                      excludeSemantics: true,
                      child: Material(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => onBrowse(tile),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 64),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: c.line),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: c.surface2,
                                      borderRadius: BorderRadius.circular(10)),
                                  child:
                                      Icon(tile.icon, size: 18, color: c.text),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(tile.label,
                                      style: TextStyle(
                                          color: c.text,
                                          fontSize: 15,
                                          height: 20 / 15,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow(
      {required this.term, required this.onTap, required this.onRemove});

  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: term,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, size: 18, color: c.text3),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(term,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: c.text,
                                fontSize: 15,
                                height: 20 / 15,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: '${AppConstants.removeRecent}: $term',
          excludeSemantics: true,
          child: InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(Icons.close_rounded, size: 16, color: c.text3),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Up to six rows under the field while typing: the plain query first, then
/// what matches, with the typed part in bold.
class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
    required this.rows,
    required this.onTap,
  });

  final List<Suggestion> rows;
  final ValueChanged<Suggestion> onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          for (final row in rows)
            Semantics(
              button: true,
              label: [
                '${row.hit}${row.rest}',
                if (row.type.isNotEmpty) row.type,
              ].join(', '),
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onTap(row),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: c.line))),
                  child: Row(
                    children: [
                      _Leading(row: row),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: row.hit,
                                    style: TextStyle(
                                        color: c.text,
                                        fontWeight: FontWeight.w700)),
                                TextSpan(text: row.rest),
                              ]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: c.text2,
                                  fontSize: 15,
                                  height: 20 / 15,
                                  fontWeight: FontWeight.w500),
                            ),
                            if (row.type.isNotEmpty)
                              Text(row.type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: c.text3,
                                      fontSize: 12,
                                      height: 16 / 12,
                                      fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Icon(Icons.north_west_rounded, size: 16, color: c.text3),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.row});

  final Suggestion row;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final entry = row.entry;
    final round = entry?.kind == SearchKind.presenter;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c.surface2,
        shape: round || entry == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round || entry == null ? null : BorderRadius.circular(8),
      ),
      child: Icon(
        entry == null ? Icons.search_rounded : _icon(entry.kind),
        size: 18,
        color: c.text2,
      ),
    );
  }

  static IconData _icon(SearchKind kind) => switch (kind) {
        SearchKind.presenter => Icons.person_outline_rounded,
        SearchKind.series || SearchKind.podcast => Icons.podcasts_rounded,
        SearchKind.sermon || SearchKind.episode => Icons.headphones_rounded,
        SearchKind.video || SearchKind.playlist => Icons.ondemand_video_rounded,
        SearchKind.live => Icons.sensors_rounded,
      };
}

/// The page title, shown before anything is typed.
class SearchTitle extends StatelessWidget {
  const SearchTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Semantics(
        header: true,
        child: Text(AppConstants.searchTitle,
            style: TextStyle(
                fontFamily: AvventoTheme.newsreader,
                color: c.text,
                fontSize: 28,
                height: 34 / 28,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
