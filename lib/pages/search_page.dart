import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/download_controller.dart';
import '../controller/search_index_controller.dart';
import '../search/search_engine.dart';
import '../search/search_filters.dart';
import '../search/search_models.dart';
import '../search/search_navigation.dart';
import '../themes/avvento_theme.dart';
import '../widgets/common/skeletons.dart';
import '../widgets/search/filter_sheet.dart';
import '../widgets/search/search_field.dart';
import '../widgets/search/search_results.dart';
import '../widgets/search/search_start.dart';
import '../widgets/search/search_tabs.dart';

/// One search across presenters, podcasts, sermons, videos and live.
///
/// Three states: the start (Recent and Browse), suggestions while typing,
/// and results with type tabs and filters.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// Suggestions follow typing after this pause.
  static const _debounce = Duration(milliseconds: 150);

  final _text = TextEditingController();
  final _focus = FocusNode();
  late final SearchIndexController _index = Get.find<SearchIndexController>();

  Timer? _timer;

  /// What suggestions are for (the text, a moment after typing).
  String _typed = '';

  /// What the results are for, once searched; empty with [_searched] means
  /// browsing a whole tab.
  String _query = '';
  bool _searched = false;
  SearchTab _tab = SearchTab.all;
  SearchFilters _filters = SearchFilters.none;

  Worker? _handover;

  @override
  void initState() {
    super.initState();
    _index.ensureLoaded();
    // "Search all of Avvento" on another page hands its query over.
    _handover = ever<String?>(_index.pendingQuery, (_) => _takeHandover());
    WidgetsBinding.instance.addPostFrameCallback((_) => _takeHandover());
  }

  void _takeHandover() {
    final query = _index.pendingQuery.value;
    if (query == null || !mounted) return;
    _index.pendingQuery.value = null;
    _submit(query);
  }

  @override
  void dispose() {
    _handover?.dispose();
    _timer?.cancel();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _isDownloaded(String id) =>
      Get.isRegistered<DownloadController>() &&
      Get.find<DownloadController>().isDownloaded(id);

  SearchResults _search(SearchTab tab, SearchFilters filters) =>
      SearchEngine.search(_index.entries, _query,
          tab: tab, filters: filters, isDownloaded: _isDownloaded);

  void _onChanged(String text) {
    _timer?.cancel();
    setState(() => _searched = false);
    if (text.trim().isEmpty) {
      setState(() => _typed = '');
      return;
    }
    _timer = Timer(_debounce, () {
      if (mounted) setState(() => _typed = text);
    });
  }

  void _submit(String text) {
    final term = text.trim();
    if (term.isEmpty) return;
    _timer?.cancel();
    _index.addRecent(term);
    _focus.unfocus();
    setState(() {
      _text.text = term;
      _typed = term;
      _query = term;
      _searched = true;
      _tab = SearchTab.all;
    });
  }

  void _browse(BrowseTile tile) {
    _timer?.cancel();
    _focus.unfocus();
    setState(() {
      _text.text = tile.query;
      _typed = tile.query;
      _query = tile.query;
      _searched = true;
      _tab = tile.tab;
    });
  }

  void _cancel() {
    _timer?.cancel();
    _focus.unfocus();
    setState(() {
      _text.clear();
      _typed = '';
      _query = '';
      _searched = false;
      _tab = SearchTab.all;
    });
  }

  void _openFilters() {
    showSearchFilterSheet(
      context,
      tab: _tab,
      filters: _filters,
      onChanged: (f) => setState(() => _filters = f),
      countFor: (f) => _search(_tab, f).hits.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The other tabs and the nav bar use the app theme's surface.
    final background = Theme.of(context).colorScheme.surface;
    return AvventoThemeScope(
      child: Builder(builder: (context) => _page(context, background)),
    );
  }

  Widget _page(BuildContext context, Color background) {
    final suggesting = !_searched &&
        SearchEngine.normalize(_typed).length >= SearchEngine.minQuery;
    final idle = !_searched && !suggesting;

    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          // Read here so the page follows the index as it fills.
          _index.entries.length;
          final loading = _index.loading.value;
          final results = _searched ? _search(_tab, _filters) : null;

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // Keys: the title comes and goes, and the field must keep its state
              // (and the keyboard) when it does.
              if (idle)
                const SliverToBoxAdapter(
                    key: ValueKey('title'), child: SearchTitle()),
              SliverToBoxAdapter(
                key: const ValueKey('field'),
                child: SearchField(
                  controller: _text,
                  focusNode: _focus,
                  onChanged: _onChanged,
                  onSubmitted: _submit,
                  onCancel: _cancel,
                ),
              ),
              if (results != null) ...[
                SliverToBoxAdapter(
                  child: SearchTabsBar(
                    tab: _tab,
                    counts: results.counts,
                    activeFilters: _filters.activeOn(_tab).length,
                    filtersEnabled: filterGroupsFor(_tab).isNotEmpty,
                    onTab: (t) => setState(() => _tab = t),
                    onFilters: _openFilters,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ActiveFilterChips(
                    chips: _filters.chipsOn(_tab),
                    onRemove: (chip) =>
                        setState(() => _filters = chip.remove(_filters)),
                  ),
                ),
                if (results.isEmpty && loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: PresenterRowsSkeleton(count: 5),
                    ),
                  )
                else if (results.isEmpty)
                  SliverToBoxAdapter(
                    child: SearchEmptyState(
                      query: _query,
                      hasFilters: _filters.activeOn(_tab).isNotEmpty,
                      onClearFilters: () =>
                          setState(() => _filters = SearchFilters.none),
                    ),
                  )
                else
                  SearchResultsSliver(
                    results: results,
                    tab: _tab,
                    onOpen: SearchNavigation.open,
                    onSeeAll: (t) => setState(() => _tab = t),
                  ),
              ] else if (suggesting)
                SliverToBoxAdapter(
                  child: SuggestionList(
                    rows: SearchEngine.suggest(_index.entries, _typed),
                    onTap: (row) {
                      final entry = row.entry;
                      _submit(entry == null ? row.hit : entry.title);
                    },
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SearchStart(
                    recent: _index.recent.toList(),
                    onRecent: _submit,
                    onRemoveRecent: _index.removeRecent,
                    onClearRecent: _index.clearRecent,
                    onBrowse: _browse,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        }),
      ),
    );
  }
}
