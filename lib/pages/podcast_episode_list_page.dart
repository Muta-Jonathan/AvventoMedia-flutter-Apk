import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/azuracast_api.dart';
import '../components/app_constants.dart';
import '../components/episode_order.dart';
import '../components/episode_playback.dart';
import '../controller/connectivity_controller.dart';
import '../controller/download_controller.dart';
import '../controller/episode_progress_controller.dart';
import '../controller/library_controller.dart';
import '../controller/podcast_controller.dart';
import '../models/radiomodel/podcast_episode_model.dart';
import '../models/radiomodel/radio_podcast_model.dart';
import '../models/saved_item_model.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/save_bottom_sheet.dart';
import '../widgets/podcast/episode/episode_actions_sheet.dart';
import '../widgets/podcast/episode/episode_download_button.dart';
import '../widgets/podcast/episode/episode_feed_tile.dart';
import '../widgets/podcast/player_state_builder.dart';
import '../widgets/podcast/podcast_palette.dart';
import '../themes/avvento_colors.dart';
import '../themes/avvento_theme.dart';

/// A podcast's page: header with Play All / Shuffle / Favorite / Save,
/// Download all, sort, then the editorial episode feed. Playback queues
/// follow the list as displayed.
class PodcastEpisodeListPage extends StatefulWidget {
  /// [fetchEpisodes] exists for tests.
  const PodcastEpisodeListPage({super.key, this.fetchEpisodes});

  final Future<List<PodcastEpisode>> Function(String url)? fetchEpisodes;

  @override
  State<PodcastEpisodeListPage> createState() => _PodcastEpisodeListPageState();
}

class _PodcastEpisodeListPageState extends State<PodcastEpisodeListPage> {
  final RadioPodcast show =
      Get.find<PodcastController>().selectedEpisode.value!;
  List<PodcastEpisode>? _episodes;
  bool _failed = false;

  /// Chosen once episodes load: in order for numbered series, else newest.
  EpisodeSort? _sort;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fetch =
        widget.fetchEpisodes ?? AzuraCastAPI.fetchRadioPodcastsEpisodes;
    try {
      final episodes = await fetch(show.episodesLink);
      if (!mounted) return;
      setState(() {
        _episodes = episodes;
        _failed = false;
        _sort ??= looksLikeSeries(episodes)
            ? EpisodeSort.inOrder
            : EpisodeSort.newest;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// API order is newest first.
  List<PodcastEpisode> get _sorted => sortEpisodes(
      _episodes ?? const <PodcastEpisode>[], _sort ?? EpisodeSort.newest);

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
      body: RefreshIndicator(
        backgroundColor: c.surface,
        color: c.accent,
        onRefresh: _load,
        child: PlayerStateBuilder(
          builder: (context, currentId, playing, progress) {
            final episodes = _sorted;
            final currentIndex = episodes.indexWhere((e) => e.id == currentId);
            final resumeIndex = _resumeIndex(episodes, progress);
            final downloads = Get.find<DownloadController>();
            final inOrder = _sort == EpisodeSort.inOrder;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    show: show,
                    episodeCount: _episodes?.length ?? show.episodes,
                    playLabel: currentIndex >= 0
                        ? (playing ? AppConstants.pause : AppConstants.resume)
                        : resumeIndex != null
                            ? AppConstants.resume
                            : AppConstants.playAll,
                    // Which episode Pause / Resume applies to.
                    playSub: currentIndex >= 0
                        ? episodes[currentIndex].title
                        : resumeIndex != null
                            ? episodes[resumeIndex].title
                            : null,
                    playing: currentIndex >= 0 && playing,
                    onPlayAll: episodes.isEmpty
                        ? null
                        : () => currentIndex < 0
                            ? EpisodePlayback.play(episodes, resumeIndex ?? 0)
                            : EpisodePlayback.toggle(episodes, currentIndex),
                    onShuffle: episodes.isEmpty
                        ? null
                        : () => EpisodePlayback.play(
                            List.of(episodes)..shuffle(), 0),
                    downloadAll: episodes.isEmpty
                        ? null
                        : _DownloadAllButton(
                            episodes: episodes, showTitle: show.title),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(AppConstants.episodes,
                              style: TextStyle(
                                  color: c.text,
                                  fontSize: 15,
                                  height: 20 / 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        _SortMenu(
                          selected: _sort ?? EpisodeSort.newest,
                          onSelected: (sort) => setState(() => _sort = sort),
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
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 24),
                    sliver: SliverList.builder(
                      itemCount: episodes.length,
                      itemBuilder: (context, i) {
                        final episode = episodes[i];
                        final isCurrent = i == currentIndex;
                        void more() =>
                            EpisodeActionsSheet.show(context, episode,
                                showTitle: show.title);
                        return Obx(() {
                          // Read both so Obx always has something to watch.
                          final downloaded = downloads.isDownloaded(episode.id);
                          final offline =
                              Get.isRegistered<ConnectivityController>() &&
                                  Get.find<ConnectivityController>()
                                      .offline
                                      .value;
                          return EpisodeFeedTile(
                            episode: episode,
                            progress:
                                progress[episode.id] ?? const EpisodeProgress(),
                            isCurrent: isCurrent,
                            isPlaying: isCurrent && playing,
                            available: !offline || downloaded,
                            numbered: inOrder,
                            onTap: () => EpisodePlayback.open(episodes, i),
                            onPlayTap: () =>
                                EpisodePlayback.toggle(episodes, i),
                            onMore: more,
                            downloadLabel:
                                EpisodeDownloadLabel(episodeId: episode.id),
                            download: EpisodeDownloadButton(
                              episode: episode,
                              showTitle: show.title,
                              onDownloaded: more,
                            ),
                          );
                        });
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Back, then a 124 cover beside the overline, title, host and count, then
/// Play All, Shuffle, Favorite and Save. No text on the cover.
class _Header extends StatelessWidget {
  const _Header({
    required this.show,
    required this.episodeCount,
    required this.playLabel,
    required this.playSub,
    required this.playing,
    required this.onPlayAll,
    required this.onShuffle,
    required this.downloadAll,
  });

  final RadioPodcast show;
  final int episodeCount;
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
    final library = Get.find<LibraryController>();
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
                      Text(AppConstants.podcastLabel,
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
                      if (episodeCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(AppConstants.episodeCount(episodeCount),
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
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    child: Material(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: onPlayAll,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 20,
                                    color: c.onAccent),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Shrinks rather than clips beside
                                      // four buttons at large text sizes.
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(playLabel,
                                            style: TextStyle(
                                                color: c.onAccent,
                                                fontSize: 15,
                                                height: 18 / 15,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                      if (playSub != null)
                                        Text(playSub!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: c.onAccent
                                                    .withValues(alpha: 0.8),
                                                fontSize: 11,
                                                height: 13 / 11,
                                                fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CircleButton(
                  icon: CupertinoIcons.shuffle,
                  label: AppConstants.shuffle,
                  iconColor: c.text,
                  onTap: onShuffle,
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final fav = library.isFavorite(show.id);
                  return _CircleButton(
                    icon:
                        fav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    label: AppConstants.addToFavorites,
                    iconColor: fav ? c.liveDot : c.text,
                    onTap: () => library.toggleFavorite(saved),
                  );
                }),
                const SizedBox(width: 8),
                Obx(() {
                  final inPlaylist = library.isInAnyPlaylist(show.id);
                  return _CircleButton(
                    icon: inPlaylist
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    label: AppConstants.saveToPlaylist,
                    iconColor: inPlaylist ? c.accent : c.text,
                    onTap: () => SaveBottomSheet.show(context, saved),
                  );
                }),
                if (downloadAll != null) ...[
                  const SizedBox(width: 8),
                  downloadAll!,
                ],
              ],
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Theme.of(context).avvento.surface2,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 48,
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
        ),
      );
}

/// Download all as a 48 circle: arrow → progress ring (tap to cancel) →
/// check (tap to remove, after asking). The ring covers the whole show.
class _DownloadAllButton extends StatelessWidget {
  const _DownloadAllButton({required this.episodes, required this.showTitle});

  final List<PodcastEpisode> episodes;
  final String showTitle;

  @override
  Widget build(BuildContext context) {
    final downloads = Get.find<DownloadController>();
    final c = Theme.of(context).avvento;

    return Obx(() {
      final done = [
        for (final e in episodes)
          if (downloads.isDownloaded(e.id)) e.id
      ];
      final active = [
        for (final e in episodes)
          if (downloads.tasks[e.id]?.active ?? false) downloads.tasks[e.id]!
      ];
      final missing =
          episodes.where((e) => !downloads.isDownloaded(e.id)).toList();

      final Widget icon;
      final String label;
      final VoidCallback onTap;
      if (active.isNotEmpty) {
        final fraction = (done.length +
                active.fold<double>(0, (sum, t) => sum + (t.fraction ?? 0))) /
            episodes.length;
        icon = DownloadRing(fraction: fraction, track: c.line);
        label = AppConstants.downloadingPercent(fraction);
        onTap = () => downloads.cancelAll(active.map((t) => t.episode.id));
      } else if (missing.isEmpty) {
        icon = const DownloadDoneBadge();
        label = AppConstants.downloadedLabel;
        onTap = () => _confirmRemove(context, downloads, done);
      } else {
        icon = Icon(Icons.download_rounded, size: 20, color: c.text);
        label = AppConstants.downloadAll(missing.length);
        onTap = () => downloads.enqueueAll(missing, showTitle: showTitle);
      }

      return Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: c.surface2,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(dimension: 48, child: Center(child: icon)),
          ),
        ),
      );
    });
  }

  Future<void> _confirmRemove(BuildContext context,
      DownloadController downloads, List<String> ids) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppConstants.removeDownloadsQuestion(ids.length)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(AppConstants.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(AppConstants.remove)),
        ],
      ),
    );
    if (ok == true) await downloads.removeAll(ids);
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
