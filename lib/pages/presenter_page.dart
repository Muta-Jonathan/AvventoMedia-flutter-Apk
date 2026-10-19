import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../components/episode_playback.dart';
import '../components/feed_kind.dart';
import '../components/utils.dart';
import '../controller/episode_progress_controller.dart';
import '../controller/presenters_controller.dart';
import '../models/presenter_model.dart';
import '../models/radiomodel/podcast_episode_model.dart';
import '../models/saved_item_model.dart';
import '../themes/avvento_colors.dart';
import '../themes/avvento_theme.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/podcast/episode/download_all_button.dart';
import '../widgets/podcast/episode/feed_episode_row.dart';
import '../widgets/podcast/feed_action_row.dart';
import '../widgets/podcast/player_state_builder.dart';
import '../widgets/podcast/podcast_palette.dart';
import '../widgets/presenters/presenter_portrait.dart';

/// A presenter: portrait, Play latest / Shuffle / Favorite / Save /
/// Download all, series in part order, then single sermons newest first.
class PresenterPage extends StatefulWidget {
  /// Defaults to the route argument. [fetch] exists for tests.
  const PresenterPage({super.key, this.presenterId, this.fetch});

  final String? presenterId;
  final Future<Presenter> Function(String id)? fetch;

  @override
  State<PresenterPage> createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage> {
  late final String _id = widget.presenterId ?? Get.arguments as String;
  Presenter? _presenter;
  bool _failed = false;

  /// Series showing all their parts.
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fetch = widget.fetch ?? Get.find<PresentersController>().detail;
    try {
      final p = await fetch(_id);
      if (mounted) setState(() => _presenter = p);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) =>
      AvventoThemeScope(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final c = Theme.of(context).avvento;
    final p = _presenter;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: p == null
            ? (_failed
                ? EmptyState(
                    icon: Icons.wifi_off_rounded,
                    color: c.accent,
                    title: AppConstants.presentersLoadFailed,
                    message: '',
                    actionLabel: AppConstants.retry,
                    actionIcon: Icons.refresh_rounded,
                    onAction: () {
                      setState(() => _failed = false);
                      _load();
                    },
                  )
                : const Center(child: LoadingWidget()))
            : PlayerStateBuilder(
                builder: (context, currentId, playing, progress) =>
                    _content(context, p, currentId, playing, progress),
              ),
      ),
    );
  }

  Widget _content(BuildContext context, Presenter p, String? currentId,
      bool playing, Map<String, EpisodeProgress> progress) {
    final c = Theme.of(context).avvento;

    /// One row; [queue] plays from it in the order shown.
    Widget tile(List<PodcastEpisode> queue, int i, String showTitle,
            {String? lead, double margin = 20}) =>
        FeedEpisodeRow(
          queue: queue,
          index: i,
          showTitle: showTitle,
          progress: progress,
          currentId: currentId,
          playing: playing,
          overlineLead: lead,
          horizontalMargin: margin,
        );

    final all = p.allSermons;
    final newestFirst = List.of(all)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(presenter: p)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: FeedActionRow(
              playLabel: AppConstants.playLatest,
              onPlay: newestFirst.isEmpty
                  ? null
                  : () => EpisodePlayback.play(newestFirst, 0),
              onShuffle: all.isEmpty
                  ? null
                  : () => EpisodePlayback.play(List.of(all)..shuffle(), 0),
              saved: SavedItem(
                id: p.id,
                type: 'presenter',
                title: p.name,
                thumbnailUrl: p.image,
                groupId: p.id,
                groupTitle: p.genre,
                savedAt: DateTime.now(),
              ),
              downloadAll: all.isEmpty
                  ? null
                  : DownloadAllButton(episodes: all, showTitle: p.name),
            ),
          ),
        ),
        if (p.series.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionTitle(
                title: AppConstants.series, count: p.series.length),
          ),
          for (final s in p.series)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SeriesHeader(
                      series: s,
                      onPlay: s.parts.isEmpty
                          ? null
                          : () {
                              // Pick up at the first unplayed part.
                              final i = s.parts.indexWhere(
                                  (e) => !(progress[e.id]?.played ?? false));
                              EpisodePlayback.play(s.parts, i < 0 ? 0 : i);
                            },
                    ),
                    for (var i = 0;
                        i <
                            (_expanded.contains(s.id)
                                ? s.parts.length
                                : s.parts.length.clamp(0, 3));
                        i++)
                      tile(s.parts, i, s.title,
                          lead: episodeNumberLead(s.parts[i], FeedKind.series),
                          margin: 0),
                    if (!_expanded.contains(s.id) && s.parts.length > 3)
                      Semantics(
                        button: true,
                        child: InkWell(
                          onTap: () => setState(() => _expanded.add(s.id)),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  AppConstants.showMoreParts(
                                      s.parts.length - 3),
                                  style: TextStyle(
                                      color: c.accentText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
        ],
        if (p.singles.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionTitle(
                title: AppConstants.singleSermons, count: p.singles.length),
          ),
          SliverList.builder(
            itemCount: p.singles.length,
            itemBuilder: (context, i) => tile(p.singles, i, p.name),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.presenter});

  final Presenter presenter;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final p = presenter;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 22, color: c.text),
                onPressed: () => Navigator.maybePop(context),
              ),
              IconButton(
                tooltip: AppConstants.share,
                icon: Icon(Icons.ios_share_rounded, size: 22, color: c.text),
                onPressed: () => Utils.share(
                    '${AppConstants.listenToPresenter(p.name)}\n${AppConstants.shareAppLink}'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Row(
            children: [
              // 112 portrait inside the ring.
              PresenterPortrait(
                  name: p.name, image: p.image, size: 102, ring: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.presenterLabel,
                        style: TextStyle(
                            color: c.accentText,
                            fontSize: 11,
                            height: 14 / 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.88)),
                    const SizedBox(height: 4),
                    Text(p.name,
                        style: TextStyle(
                            fontFamily: AvventoTheme.newsreader,
                            color: c.text,
                            fontSize: 26,
                            height: 31 / 26,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        [
                          AppConstants.sermonCount(p.sermonCount),
                          if (p.seriesCount > 0)
                            AppConstants.seriesCount(p.seriesCount),
                        ].join(' · '),
                        style: TextStyle(
                            color: c.text2,
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(title,
              style: TextStyle(
                  color: c.text,
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w700)),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('$count',
                style: TextStyle(
                    color: c.text3, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// Cover, title, "6 parts", Play and Download all.
class _SeriesHeader extends StatelessWidget {
  const _SeriesHeader({required this.series, required this.onPlay});

  final SermonSeries series;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(
        children: [
          PodcastArt(url: series.cover, size: 48, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(series.title,
                    style: TextStyle(
                        color: c.text,
                        fontSize: 16,
                        height: 21 / 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(AppConstants.partCount(series.parts.length),
                    style: TextStyle(
                        color: c.text3,
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: AppConstants.playSeries(series.title),
            excludeSemantics: true,
            child: Material(
              color: c.accentSoft,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPlay,
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(Icons.play_arrow_rounded,
                      size: 22, color: c.accentText),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DownloadAllButton(
              episodes: series.parts, showTitle: series.title, dimension: 44),
        ],
      ),
    );
  }
}
