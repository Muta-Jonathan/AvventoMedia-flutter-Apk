import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../apis/azuracast_api.dart';
import '../components/app_constants.dart';
import '../components/episode_order.dart';
import '../components/feed_kind.dart';
import '../components/episode_playback.dart';
import '../controller/episode_progress_controller.dart';
import '../controller/podcast_controller.dart';
import '../models/radiomodel/podcast_episode_model.dart';
import '../models/radiomodel/radio_podcast_model.dart';
import '../models/saved_item_model.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/podcast/episode/download_all_button.dart';
import '../widgets/podcast/episode/feed_episode_row.dart';
import '../widgets/podcast/feed_action_row.dart';
import '../widgets/podcast/player_state_builder.dart';
import '../widgets/podcast/podcast_palette.dart';
import '../themes/avvento_colors.dart';
import '../themes/avvento_theme.dart';

/// A podcast's page: header with Play All / Shuffle / Favorite / Save /
/// Download all, sort, then the editorial episode feed. Bible shows group
/// chapters by book with a book jump; Ellen G. White books list chapters.
/// Playback queues follow the list as displayed.
class PodcastEpisodeListPage extends StatefulWidget {
  /// [fetchEpisodes] and [cachedEpisodes] exist for tests.
  const PodcastEpisodeListPage(
      {super.key, this.fetchEpisodes, this.cachedEpisodes});

  final Future<List<PodcastEpisode>> Function(String url)? fetchEpisodes;
  final Future<List<PodcastEpisode>?> Function(String url)? cachedEpisodes;

  @override
  State<PodcastEpisodeListPage> createState() => _PodcastEpisodeListPageState();
}

class _PodcastEpisodeListPageState extends State<PodcastEpisodeListPage> {
  final RadioPodcast show =
      Get.find<PodcastController>().selectedEpisode.value!;
  List<PodcastEpisode>? _episodes;
  bool _failed = false;

  /// Chosen once episodes load: in order for series, books and the Bible,
  /// else newest.
  EpisodeSort? _sort;
  FeedKind _kind = FeedKind.show;

  /// Pinned book headers, in Bible order, for the book jump.
  final Map<int, GlobalKey> _bookKeys = {};
  int? _currentBook;

  /// The picked book stays shown while the jump scrolls (a short last
  /// book can't reach the top).
  bool _jumping = false;

  @override
  void dispose() {
    _bookKeys.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Shows the episodes saved last time at once, then the fresh list. The
  /// server can take seconds for big feeds like the Old Testament.
  Future<void> _load() async {
    final fetch =
        widget.fetchEpisodes ?? AzuraCastAPI.fetchRadioPodcastsEpisodes;
    // Started first and caught at once, so a quick failure isn't unhandled
    // while the cache loads.
    final fresh = fetch(show.episodesLink)
        .then<Object>((episodes) => episodes, onError: (Object e) => e);
    if (_episodes == null) {
      final cached =
          widget.cachedEpisodes ?? AzuraCastAPI.cachedRadioPodcastsEpisodes;
      try {
        final saved = await cached(show.episodesLink);
        if (saved != null && saved.isNotEmpty && _episodes == null) {
          _show(saved);
        }
      } catch (_) {
        // A bad cache just means waiting for the network.
      }
    }
    final result = await fresh;
    if (result is List<PodcastEpisode>) {
      _show(result);
    } else if (mounted && _episodes == null) {
      // Saved episodes stay on screen if the refresh fails.
      setState(() => _failed = true);
    }
  }

  void _show(List<PodcastEpisode> episodes) {
    if (!mounted) return;
    setState(() {
      _episodes = episodes;
      _failed = false;
      _kind = feedKindOf(show.title, episodes);
      _sort ??= defaultSort(_kind);
    });
  }

  /// API order is newest first.
  List<PodcastEpisode> get _sorted => sortEpisodes(
      _episodes ?? const <PodcastEpisode>[], _sort ?? EpisodeSort.newest,
      kind: _kind);

  /// Under "Resume": "Ch. 2" for books, else the episode title.
  String _shortTitle(PodcastEpisode e) {
    final n = seriesNumber(e);
    return _kind == FeedKind.egwBook && n != null
        ? AppConstants.chapterShort(n)
        : episodeDisplayTitle(e, _kind);
  }

  /// Consecutive runs of the same Bible book in the displayed list.
  List<_BookGroup> _bookGroups(List<PodcastEpisode> episodes) {
    final groups = <_BookGroup>[];
    for (var i = 0; i < episodes.length; i++) {
      final book = bibleRef(episodes[i])?.book ?? 0;
      if (groups.isNotEmpty && groups.last.book == book) {
        groups.last.count++;
      } else {
        groups.add(_BookGroup(book, i));
      }
    }
    return groups;
  }

  /// The book whose header is pinned at the top.
  void _updateCurrentBook() {
    if (_jumping) return;
    int? current;
    for (final entry in _bookKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport == null) continue;
      final dy = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
      if (dy <= 1) current = entry.key;
    }
    if (current != null && current != _currentBook) {
      setState(() => _currentBook = current);
    }
  }

  /// Scrolls the book's header to the top. Lists below the screen only
  /// estimate their height, so it settles over a few frames.
  Future<void> _jumpToBook(int book) async {
    setState(() {
      _currentBook = book;
      _jumping = true;
    });
    try {
      for (var i = 0; i < 4; i++) {
        final ctx = _bookKeys[book]?.currentContext;
        if (ctx == null || !ctx.mounted) return;
        await Scrollable.ensureVisible(ctx);
        await WidgetsBinding.instance.endOfFrame;
      }
    } finally {
      _jumping = false;
    }
  }

  Future<void> _openBookPicker(BuildContext context, List<int> books) async {
    final book = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BookPicker(books: books, current: _currentBook),
    );
    if (book != null) _jumpToBook(book);
  }

  /// In order with some progress: the first unplayed episode, to resume
  /// the series there. Null starts from the top.
  int? _resumeIndex(
      List<PodcastEpisode> episodes, Map<String, EpisodeProgress> progress) {
    if (_sort != EpisodeSort.inOrder) return null;
    EpisodeProgress p(PodcastEpisode e) =>
        progress[e.id] ?? const EpisodeProgress();
    final started =
        episodes.any((e) => p(e).played || p(e).position > Duration.zero);
    if (!started) return null;
    final i = episodes.indexWhere((e) => !p(e).played);
    return i < 0 ? null : i;
  }

  @override
  Widget build(BuildContext context) =>
      AvventoThemeScope(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final c = Theme.of(context).avvento;

    return Scaffold(
      backgroundColor: c.bg,
      // Pinned book headers stick below the status bar.
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          backgroundColor: c.surface,
          color: c.accent,
          onRefresh: _load,
          child: PlayerStateBuilder(
            builder: (context, currentId, playing, progress) {
              final episodes = _sorted;
              final currentIndex =
                  episodes.indexWhere((e) => e.id == currentId);
              final resumeIndex = _resumeIndex(episodes, progress);
              final inOrder = _sort == EpisodeSort.inOrder;
              final groups = _kind == FeedKind.bible && inOrder
                  ? _bookGroups(episodes)
                  : const <_BookGroup>[];
              final books = [
                for (final g in groups)
                  if (g.book > 0) g.book
              ];
              if (books.isNotEmpty && !books.contains(_currentBook)) {
                _currentBook = books.first;
              }

              Widget tile(int i) => FeedEpisodeRow(
                    queue: episodes,
                    index: i,
                    showTitle: show.title,
                    progress: progress,
                    currentId: currentId,
                    playing: playing,
                    title: episodeDisplayTitle(episodes[i], _kind),
                    showSummary: _kind != FeedKind.egwBook,
                    overlineLead:
                        inOrder ? episodeNumberLead(episodes[i], _kind) : null,
                  );

              return NotificationListener<ScrollUpdateNotification>(
                onNotification: (_) {
                  if (books.length > 1) _updateCurrentBook();
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Header(
                        show: show,
                        overline: switch (_kind) {
                          FeedKind.bible => AppConstants.bibleLabel,
                          FeedKind.egwBook => AppConstants.egwLabel,
                          _ => AppConstants.podcastLabel,
                        },
                        meta: _kind == FeedKind.egwBook
                            ? AppConstants.chapterCount(
                                _episodes?.length ?? show.episodes)
                            : AppConstants.episodeCount(
                                _episodes?.length ?? show.episodes),
                        playLabel: currentIndex >= 0
                            ? (playing
                                ? AppConstants.pause
                                : AppConstants.resume)
                            : resumeIndex != null
                                ? AppConstants.resume
                                : AppConstants.playAll,
                        // Which episode Pause / Resume applies to.
                        playSub: currentIndex >= 0
                            ? _shortTitle(episodes[currentIndex])
                            : resumeIndex != null
                                ? _shortTitle(episodes[resumeIndex])
                                : null,
                        playing: currentIndex >= 0 && playing,
                        onPlayAll: episodes.isEmpty
                            ? null
                            : () => currentIndex < 0
                                ? EpisodePlayback.play(
                                    episodes, resumeIndex ?? 0)
                                : EpisodePlayback.toggle(
                                    episodes, currentIndex),
                        onShuffle: episodes.isEmpty
                            ? null
                            : () => EpisodePlayback.play(
                                List.of(episodes)..shuffle(), 0),
                        downloadAll: episodes.isEmpty
                            ? null
                            : DownloadAllButton(
                                episodes: episodes, showTitle: show.title),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                        child: Row(
                          children: [
                            if (books.length > 1)
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _BookPill(
                                    label: bibleBooks[
                                            (_currentBook ?? books.first) - 1]
                                        .name,
                                    onTap: () =>
                                        _openBookPicker(context, books),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Text(
                                    _kind == FeedKind.egwBook
                                        ? AppConstants.chapterCount(
                                            episodes.length)
                                        : AppConstants.episodes,
                                    style: TextStyle(
                                        color: c.text,
                                        fontSize: 15,
                                        height: 20 / 15,
                                        fontWeight: FontWeight.w700)),
                              ),
                            const SizedBox(width: 8),
                            _SortMenu(
                              selected: _sort ?? EpisodeSort.newest,
                              onSelected: (sort) =>
                                  setState(() => _sort = sort),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_episodes == null && !_failed)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: LoadingWidget(),
                        ),
                      )
                    else if (episodes.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _failed
                            ? EmptyState(
                                icon: Icons.wifi_off_rounded,
                                color: c.accent,
                                title: AppConstants.episodesLoadFailed,
                                message: AppConstants.episodesLoadFailedMessage,
                                actionLabel: AppConstants.retry,
                                actionIcon: Icons.refresh_rounded,
                                onAction: () {
                                  setState(() => _failed = false);
                                  _load();
                                },
                              )
                            : EmptyState(
                                icon: Icons.podcasts_rounded,
                                color: c.accent,
                                title: AppConstants.noEpisodes,
                                message: '',
                              ),
                      )
                    else if (groups.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 24),
                        sliver: SliverList.builder(
                          itemCount: episodes.length,
                          itemBuilder: (context, i) => tile(i),
                        ),
                      )
                    else ...[
                      // One group per book; its header stays pinned while the
                      // book is on screen.
                      for (final g in groups)
                        SliverMainAxisGroup(slivers: [
                          if (g.book > 0)
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _BookHeaderDelegate(
                                headerKey: _bookKeys.putIfAbsent(
                                    g.book, GlobalKey.new),
                                book: bibleBooks[g.book - 1],
                                colors: c,
                                textScaler: MediaQuery.textScalerOf(context),
                                onTap: books.length > 1
                                    ? () => _openBookPicker(context, books)
                                    : null,
                              ),
                            ),
                          SliverList.builder(
                            itemCount: g.count,
                            itemBuilder: (context, j) => tile(g.start + j),
                          ),
                        ]),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BookGroup {
  _BookGroup(this.book, this.start);

  /// 1-based Bible book, or 0 for titles that aren't a chapter.
  final int book;
  final int start;
  int count = 1;
}

/// Back, then a 124 cover beside the overline, title, host and count, then
/// Play All, Shuffle, Favorite and Save. No text on the cover.
class _Header extends StatelessWidget {
  const _Header({
    required this.show,
    required this.overline,
    required this.meta,
    required this.playLabel,
    required this.playSub,
    required this.playing,
    required this.onPlayAll,
    required this.onShuffle,
    required this.downloadAll,
  });

  final RadioPodcast show;

  /// "PODCAST", "BIBLE" or "ELLEN G. WHITE".
  final String overline;

  /// "748 episodes" or "31 chapters".
  final String meta;
  final String playLabel;

  /// Episode title on a second line, e.g. under "Resume".
  final String? playSub;
  final bool playing;
  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;
  final Widget? downloadAll;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final saved = SavedItem(
      id: show.id,
      type: 'podcast_show',
      title: show.title,
      thumbnailUrl: show.art,
      groupId: show.id,
      groupTitle: show.title,
      description: show.description,
      publishedAtItem: show.lastUpdated.toIso8601String(),
      savedAt: DateTime.now(),
    );

    return SafeArea(
      top: false, // The page handles the top inset.
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
            child: Semantics(
              button: true,
              label: MaterialLocalizations.of(context).backButtonTooltip,
              child: InkResponse(
                onTap: () => Navigator.maybePop(context),
                radius: 22,
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 22, color: c.text),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                PodcastArt(url: show.art, size: 124, radius: 14),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(overline,
                          style: TextStyle(
                              color: c.accentText,
                              fontSize: 11,
                              height: 14 / 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.88)),
                      const SizedBox(height: 4),
                      Text(show.title,
                          style: TextStyle(
                              fontFamily: AvventoTheme.newsreader,
                              color: c.text,
                              fontSize: 22,
                              height: 27 / 22,
                              fontWeight: FontWeight.w600)),
                      if (show.author.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(show.author,
                            style: TextStyle(
                                color: c.text2,
                                fontSize: 13,
                                height: 18 / 13,
                                fontWeight: FontWeight.w500)),
                      ],
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(meta,
                            style: TextStyle(
                                color: c.text3,
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (show.description.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _Description(
                  text: show.description.trim(), title: show.title),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: FeedActionRow(
              playLabel: playLabel,
              playSub: playSub,
              playing: playing,
              onPlay: onPlayAll,
              onShuffle: onShuffle,
              saved: saved,
              downloadAll: downloadAll,
            ),
          ),
        ],
      ),
    );
  }
}

/// Three lines with a "more" link that opens the full text.
class _Description extends StatelessWidget {
  const _Description({required this.text, required this.title});

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final style = TextStyle(color: c.text2, fontSize: 13, height: 19 / 13);

    return LayoutBuilder(builder: (context, constraints) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 3,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: constraints.maxWidth);
      final overflows = painter.didExceedMaxLines;

      return GestureDetector(
        onTap: overflows ? () => _showFull(context) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text,
                maxLines: 3, overflow: TextOverflow.ellipsis, style: style),
            if (overflows)
              Text(AppConstants.moreLower,
                  style: TextStyle(
                      color: c.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
          ],
        ),
      );
    });
  }

  void _showFull(BuildContext context) {
    final c = Theme.of(context).avvento;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(title,
                style: TextStyle(
                    fontFamily: AvventoTheme.newsreader,
                    color: c.text,
                    fontSize: 22,
                    height: 27 / 22,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(text,
                style: TextStyle(color: c.text2, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

/// Sort pill ("In order" / "Newest first" / "Oldest first") that opens a
/// small menu with a check on the current choice.
class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.selected, required this.onSelected});

  final EpisodeSort selected;
  final ValueChanged<EpisodeSort> onSelected;

  static const _labels = {
    EpisodeSort.inOrder: AppConstants.inOrder,
    EpisodeSort.newest: AppConstants.newestFirst,
    EpisodeSort.oldest: AppConstants.oldestFirst,
  };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return PopupMenuButton<EpisodeSort>(
      tooltip: AppConstants.sort,
      initialValue: selected,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 2),
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
      menuPadding: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.line),
      ),
      itemBuilder: (_) => [
        for (final sort in EpisodeSort.values)
          PopupMenuItem(
            value: sort,
            height: 44,
            padding: EdgeInsets.zero,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: sort == selected ? c.surface2 : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_labels[sort]!,
                        style: TextStyle(
                            color: c.text,
                            fontSize: 14,
                            height: 18 / 14,
                            fontWeight: FontWeight.w600)),
                  ),
                  if (sort == selected)
                    Icon(Icons.check_rounded, size: 18, color: c.accentText),
                ],
              ),
            ),
          ),
      ],
      // The 36 pill sits in a 44 hit area.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Center(
          widthFactor: 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded, size: 16, color: c.text),
                const SizedBox(width: 8),
                Text(_labels[selected]!,
                    style: TextStyle(
                        color: c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: c.text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Current book, opening the book jump. A 36 pill in a 44 hit area.
class _BookPill extends StatelessWidget {
  const _BookPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Semantics(
      button: true,
      label: '${AppConstants.jumpToBook}, $label',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Center(
            widthFactor: 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, size: 16, color: c.text),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(label,
                        style: TextStyle(
                            color: c.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: c.text3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Genesis  50 chapters", pinned while the book is on screen. Tapping it
/// opens the book jump, so another book is one tap away mid-scroll.
class _BookHeaderDelegate extends SliverPersistentHeaderDelegate {
  _BookHeaderDelegate({
    required this.headerKey,
    required this.book,
    required this.colors,
    required this.textScaler,
    this.onTap,
  });

  final GlobalKey headerKey;
  final BibleBook book;
  final AvventoColors colors;
  final TextScaler textScaler;

  /// Null when the feed has a single book.
  final VoidCallback? onTap;

  @override
  double get maxExtent => 16 + textScaler.scale(28) + 6;

  @override
  double get minExtent => maxExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final header = Container(
      key: headerKey,
      color: colors.bg,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      alignment: Alignment.bottomLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(book.name,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontFamily: AvventoTheme.newsreader,
                    color: colors.text,
                    fontSize: 21,
                    height: 28 / 21,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(AppConstants.chapterCount(book.chapters),
              maxLines: 1,
              style: TextStyle(
                  color: colors.text3,
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500)),
          if (onTap != null) ...[
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: colors.text3),
          ],
        ],
      ),
    );
    if (onTap == null) return header;
    return Semantics(
      button: true,
      label: '${AppConstants.jumpToBook}, ${book.name}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: header,
      ),
    );
  }

  @override
  bool shouldRebuild(_BookHeaderDelegate old) =>
      old.book != book ||
      old.colors != colors ||
      old.textScaler != textScaler ||
      old.headerKey != headerKey ||
      (old.onTap == null) != (onTap == null);
}

/// "Jump to book": Old/New Testament toggle (when the feed has both) and a
/// 3-column grid of the feed's books. Pops the chosen book.
class _BookPicker extends StatefulWidget {
  const _BookPicker({required this.books, required this.current});

  final List<int> books;
  final int? current;

  @override
  State<_BookPicker> createState() => _BookPickerState();
}

class _BookPickerState extends State<_BookPicker> {
  late bool _newTestament =
      (widget.current ?? widget.books.first) > oldTestamentBooks;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final scaler = MediaQuery.textScalerOf(context);
    final hasOld = widget.books.any((b) => b <= oldTestamentBooks);
    final hasNew = widget.books.any((b) => b > oldTestamentBooks);
    final shown = [
      for (final b in widget.books)
        if (!(hasOld && hasNew) || (b > oldTestamentBooks) == _newTestament) b
    ];

    Widget testament(String label, bool isNew) {
      final on = _newTestament == isNew;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          child: Material(
            color: on ? c.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => setState(() => _newTestament = isNew),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 38),
                child: Center(
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: on ? c.onAccent : c.text2,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(AppConstants.jumpToBook,
                      style: TextStyle(
                          fontFamily: AvventoTheme.newsreader,
                          color: c.text,
                          fontSize: 22,
                          height: 28 / 22,
                          fontWeight: FontWeight.w600)),
                ),
                Transform.translate(
                  offset: const Offset(10, 0),
                  child: IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: c.text),
                  ),
                ),
              ],
            ),
            if (hasOld && hasNew)
              Container(
                margin: const EdgeInsets.fromLTRB(0, 8, 0, 14),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: c.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  testament(AppConstants.oldTestament, false),
                  testament(AppConstants.newTestament, true),
                ]),
              )
            else
              const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                    bottom: 24 + MediaQuery.paddingOf(context).bottom),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  // Room for two-line names ("1 Thessalonians").
                  mainAxisExtent: 16 + scaler.scale(36) + 2 + scaler.scale(14),
                ),
                itemCount: shown.length,
                itemBuilder: (context, i) {
                  final book = bibleBooks[shown[i] - 1];
                  final on = shown[i] == widget.current;
                  return Semantics(
                    button: true,
                    selected: on,
                    child: Material(
                      color: on ? c.accent : c.surface2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context, shown[i]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book.name,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: on ? c.onAccent : c.text,
                                      fontSize: 14,
                                      height: 18 / 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(AppConstants.chaptersAbbrev(book.chapters),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      color: on ? c.onAccent : c.text3,
                                      fontSize: 11,
                                      height: 14 / 11,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
