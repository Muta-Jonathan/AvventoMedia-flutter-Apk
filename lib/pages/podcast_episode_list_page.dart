import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/azuracast_api.dart';
import '../components/app_constants.dart';
import '../components/episode_playback.dart';
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

/// A podcast's page: header with Play All / Shuffle / Favorite / Save, then
/// the editorial episode feed.
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
  bool _oldestFirst = false;

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
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// API order is newest first.
  List<PodcastEpisode> get _sorted {
    final list = _episodes ?? const <PodcastEpisode>[];
    return _oldestFirst ? list.reversed.toList() : list;
  }

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: PodcastPalette.accent,
        onRefresh: _load,
        child: PlayerStateBuilder(
          builder: (context, currentId, playing, progress) {
            final episodes = _sorted;
            final currentIndex = episodes.indexWhere((e) => e.id == currentId);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    show: show,
                    episodeCount: _episodes?.length ?? show.episodes,
                    playAllLabel: currentIndex < 0
                        ? AppConstants.playAll
                        : playing
                            ? AppConstants.pause
                            : AppConstants.resume,
                    playing: currentIndex >= 0 && playing,
                    onPlayAll: episodes.isEmpty
                        ? null
                        : () => currentIndex < 0
                            ? EpisodePlayback.play(episodes, 0)
                            : EpisodePlayback.toggle(episodes, currentIndex),
                    onShuffle: episodes.isEmpty
                        ? null
                        : () => EpisodePlayback.play(
                            List.of(episodes)..shuffle(), 0),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 6),
                    child: Row(
                      children: [
                        Text(AppConstants.episodes,
                            style: TextStyle(
                                color: palette.title,
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        _SortChip(
                          label: _oldestFirst
                              ? AppConstants.oldest
                              : AppConstants.newest,
                          onTap: () =>
                              setState(() => _oldestFirst = !_oldestFirst),
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
                            color: PodcastPalette.accent,
                            title: AppConstants.episodesLoadFailed,
                            message: AppConstants.episodesLoadFailedMessage,
                            actionLabel: AppConstants.retry,
                            actionIcon: Icons.refresh_rounded,
                            onAction: () {
                              setState(() => _failed = false);
                              _load();
                            },
                          )
                        : const EmptyState(
                            icon: Icons.podcasts_rounded,
                            color: PodcastPalette.accent,
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
                        return EpisodeFeedTile(
                          episode: episode,
                          progress:
                              progress[episode.id] ?? const EpisodeProgress(),
                          isCurrent: isCurrent,
                          isPlaying: isCurrent && playing,
                          onTap: () => EpisodePlayback.open(episodes, i),
                          onPlayTap: () => EpisodePlayback.toggle(episodes, i),
                          onMore: more,
                          download: EpisodeDownloadButton(
                            episode: episode,
                            showTitle: show.title,
                            onDownloaded: more,
                          ),
                        );
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

class _Header extends StatelessWidget {
  const _Header({
    required this.show,
    required this.episodeCount,
    required this.playAllLabel,
    required this.playing,
    required this.onPlayAll,
    required this.onShuffle,
  });

  final RadioPodcast show;
  final int episodeCount;
  final String playAllLabel;
  final bool playing;
  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.headerGlow, palette.headerGlow.withValues(alpha: 0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                label: MaterialLocalizations.of(context).backButtonTooltip,
                color:
                    Colors.black.withValues(alpha: palette.dark ? 0.3 : 0.06),
                iconColor: palette.title,
                size: 40,
                onTap: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black
                                .withValues(alpha: palette.dark ? 0.5 : 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 12)),
                      ],
                    ),
                    child: PodcastArt(url: show.art, size: 132, radius: 14),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppConstants.podcastLabel,
                              style: TextStyle(
                                  color: palette.highlight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 4),
                          Text(show.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: palette.title,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15)),
                          if (show.author.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(show.author,
                                style: TextStyle(
                                    color: palette.subtitle, fontSize: 13)),
                          ],
                          if (episodeCount > 0) ...[
                            const SizedBox(height: 2),
                            Text(AppConstants.episodeCount(episodeCount),
                                style: TextStyle(
                                    color: palette.muted, fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (show.description.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                _Description(text: show.description.trim(), title: show.title),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      child: Material(
                        color: PodcastPalette.accent,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: onPlayAll,
                          child: SizedBox(
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.black),
                                const SizedBox(width: 6),
                                Text(playAllLabel,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CircleButton(
                    icon: CupertinoIcons.shuffle,
                    label: AppConstants.shuffle,
                    color: palette.button,
                    iconColor: palette.title,
                    onTap: onShuffle,
                  ),
                  const SizedBox(width: 10),
                  Obx(() {
                    final fav = library.isFavorite(show.id);
                    return _CircleButton(
                      icon: fav
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      label: AppConstants.addToFavorites,
                      color: palette.button,
                      iconColor: fav ? const Color(0xFFFF5252) : palette.title,
                      onTap: () => library.toggleFavorite(saved),
                    );
                  }),
                  const SizedBox(width: 10),
                  Obx(() {
                    final inPlaylist = library.isInAnyPlaylist(show.id);
                    return _CircleButton(
                      icon: inPlaylist
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.bookmark,
                      label: AppConstants.saveToPlaylist,
                      color: palette.button,
                      iconColor:
                          inPlaylist ? PodcastPalette.accent : palette.title,
                      onTap: () => SaveBottomSheet.show(context, saved),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
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
    final palette = PodcastPalette(context);
    final style = TextStyle(color: palette.subtitle, fontSize: 13, height: 1.5);

    return LayoutBuilder(builder: (context, constraints) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 3,
        textDirection: Directionality.of(context),
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
                      color: palette.title,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
          ],
        ),
      );
    });
  }

  void _showFull(BuildContext context) {
    final palette = PodcastPalette(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.sheet,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(title,
                style: TextStyle(
                    color: palette.title,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(text,
                style: TextStyle(
                    color: palette.subtitle, fontSize: 15, height: 1.5)),
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
    required this.color,
    required this.iconColor,
    required this.onTap,
    this.size = 48,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
        ),
      );
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_vert_rounded, size: 16, color: palette.subtitle),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: palette.subtitle, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
