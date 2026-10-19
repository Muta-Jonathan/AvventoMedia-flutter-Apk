import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/common/skeletons.dart';
import '../components/app_constants.dart';
import '../components/episode_playback.dart';
import '../components/utils.dart';
import '../controller/episode_progress_controller.dart';
import '../controller/presenters_controller.dart';
import '../models/presenter_model.dart';
import '../models/saved_item_model.dart';
import '../routes/routes.dart';
import '../themes/avvento_colors.dart';
import '../themes/avvento_theme.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/podcast/episode/download_all_button.dart';
import '../widgets/podcast/episode/feed_episode_row.dart';
import '../widgets/podcast/feed_action_row.dart';
import '../widgets/podcast/player_state_builder.dart';
import '../widgets/podcast/podcast_palette.dart';
import '../widgets/presenters/presenter_portrait.dart';

/// A presenter: portrait, Play latest / Shuffle / Favorite / Save /
/// Download all, then Series (a grid; each opens [SeriesPage]) and
/// Sermons tabs. One section without tabs when there's only one kind.
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

  /// Selected tab per presenter, kept while the app runs.
  static final Map<String, int> _tabs = {};
  int get _tab => _tabs[_id] ?? 0;

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
      // Opening the presenter clears their new-sermon ring.
      if (Get.isRegistered<PresentersController>()) {
        Get.find<PresentersController>().markSeen(p);
      }
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
                : const _LoadingPage())
            : PlayerStateBuilder(
                builder: (context, currentId, playing, progress) =>
                    _content(context, p, currentId, playing, progress),
              ),
      ),
    );
  }

  Widget _content(BuildContext context, Presenter p, String? currentId,
      bool playing, Map<String, EpisodeProgress> progress) {
    final all = p.allSermons;
    final newestFirst = List.of(all)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final tabbed = p.series.isNotEmpty && p.singles.isNotEmpty;
    final showSeries = p.series.isNotEmpty && (!tabbed || _tab == 0);

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
                  : () => EpisodePlayback.play(newestFirst, 0,
                      showTitle: p.name),
              onShuffle: all.isEmpty
                  ? null
                  : () => EpisodePlayback.play(List.of(all)..shuffle(), 0,
                      showTitle: p.name),
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
        if (tabbed)
          SliverToBoxAdapter(
            child: _Tabs(
              selected: _tab,
              tabs: [
                (AppConstants.series, p.series.length),
                (AppConstants.sermonsTab, p.singles.length),
              ],
              onSelect: (i) => setState(() => _tabs[_id] = i),
            ),
          ),
        if (showSeries)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.crossAxisExtent < 280 ? 1 : 2;
                final width =
                    (constraints.crossAxisExtent - 12 * (columns - 1)) /
                        columns;
                final rows = (p.series.length / columns).ceil();
                return SliverList.builder(
                  itemCount: rows,
                  itemBuilder: (context, r) => Padding(
                    padding: EdgeInsets.only(top: r == 0 ? 0 : 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var col = 0; col < columns; col++) ...[
                          if (col > 0) const SizedBox(width: 12),
                          SizedBox(
                            width: width,
                            child: r * columns + col < p.series.length
                                ? _SeriesCard(
                                    series: p.series[r * columns + col],
                                    size: width,
                                    progress: progress,
                                    onTap: () => Get.toNamed(
                                        Routes.getPresenterSeriesRoute(),
                                        arguments: (
                                          p,
                                          p.series[r * columns + col]
                                        )),
                                  )
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else ...[
          if (!tabbed)
            SliverToBoxAdapter(
              child: _SectionTitle(
                  title: AppConstants.singleSermons, count: p.singles.length),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverList.builder(
            itemCount: p.singles.length,
            itemBuilder: (context, i) => FeedEpisodeRow(
              queue: p.singles,
              index: i,
              showTitle: p.name,
              progress: progress,
              currentId: currentId,
              playing: playing,
            ),
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
              PresenterPortrait(name: p.name, image: p.image, size: 112),
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

/// Series | Sermons, with counts. Segmented: a surface2 track, the
/// selected tab on surface.
class _Tabs extends StatelessWidget {
  const _Tabs(
      {required this.selected, required this.tabs, required this.onSelect});

  final int selected;
  final List<(String, int)> tabs;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: c.surface2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                child: Material(
                  color: i == selected ? c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => onSelect(i),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 42),
                      child: Center(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: tabs[i].$1,
                                style: TextStyle(
                                    color: i == selected ? c.text : c.text2,
                                    fontSize: 14,
                                    height: 18 / 14,
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: '  ${tabs[i].$2}',
                                style: TextStyle(
                                    color: c.text3,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Square cover, title, "6 parts"; once started, a bar and "2 of 6".
class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.series,
    required this.size,
    required this.progress,
    required this.onTap,
  });

  final SermonSeries series;
  final double size;
  final Map<String, EpisodeProgress> progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final total = series.parts.length;
    final done =
        series.parts.where((e) => progress[e.id]?.played ?? false).length;
    final started = series.parts.any((e) {
      final p = progress[e.id];
      return p != null && (p.played || p.position > Duration.zero);
    });
    return Semantics(
      button: true,
      label: [
        series.title,
        AppConstants.partCount(total),
        if (started) AppConstants.partsOf(done, total),
      ].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PodcastArt(url: series.cover, size: size, radius: 14),
            const SizedBox(height: 10),
            Text(series.title,
                style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    height: 20 / 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(AppConstants.partCount(total),
                style: TextStyle(
                    color: c.text3,
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500)),
            if (started) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 3,
                        backgroundColor: c.surface2,
                        color: c.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(AppConstants.partsOf(done, total),
                      style: TextStyle(
                          color: c.accentText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Back button over the page's skeleton while the presenter loads.
class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 22, color: c.text),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
          ),
          const PresenterPageSkeleton(),
        ],
      ),
    );
  }
}
