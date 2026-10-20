import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../components/episode_playback.dart';
import '../../controller/episode_progress_controller.dart';
import '../../models/presenter_model.dart';
import '../../models/radiomodel/podcast_episode_model.dart';
import '../../search/search_engine.dart';
import '../../search/search_models.dart';
import '../../themes/avvento_colors.dart';
import '../common/media_list_row.dart';
import '../listen/section_header.dart';
import '../podcast/episode/feed_episode_row.dart';
import '../podcast/player_state_builder.dart';
import '../podcast/podcast_palette.dart';
import '../presenters/presenter_portrait.dart';

/// How many of a section show on the All tab before "See all".
const _allLimit = {
  SearchKind.presenter: 3,
  SearchKind.podcast: 8,
  SearchKind.sermon: 4,
  SearchKind.video: 3,
  SearchKind.live: 3,
};

/// The results as slivers: Top result, then a section per type on All, or
/// the one type on its tab.
class SearchResultsSliver extends StatelessWidget {
  const SearchResultsSliver({
    super.key,
    required this.results,
    required this.tab,
    required this.onOpen,
    required this.onSeeAll,
  });

  final SearchResults results;
  final SearchTab tab;
  final ValueChanged<SearchEntry> onOpen;
  final ValueChanged<SearchTab> onSeeAll;

  @override
  Widget build(BuildContext context) {
    return PlayerStateBuilder(
      builder: (context, currentId, playing, progress) {
        final rows = _rows(context, currentId, playing, progress);
        return SliverList.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) => rows[i](context),
        );
      },
    );
  }

  List<WidgetBuilder> _rows(BuildContext context, String? currentId,
      bool playing, Map<String, EpisodeProgress> progress) {
    final onAll = tab == SearchTab.all;
    final rows = <WidgetBuilder>[];

    List<T> limited<T>(List<T> list, SearchKind kind) =>
        onAll ? list.take(_allLimit[kind]!).toList() : list;

    void section(String title, SearchTab target, int total, int shown) {
      rows.add((_) => ListenSectionHeader(
            title: title,
            action: onAll && total > shown ? AppConstants.seeAll : null,
            onAction: () => onSeeAll(target),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 2),
          ));
    }

    final top = results.top;
    if (onAll && top != null) {
      rows
        ..add((_) => const _Title(AppConstants.topResult))
        ..add((_) => TopResultCard(hit: top, onOpen: onOpen));
    }

    final presenters = results.of(SearchKind.presenter);
    if (presenters.isNotEmpty) {
      final shown = limited(presenters, SearchKind.presenter);
      section(AppConstants.presenters, SearchTab.presenters, presenters.length,
          shown.length);
      for (final h in shown) {
        rows.add((_) => PresenterResultRow(hit: h, onOpen: onOpen));
      }
    }

    final podcasts = [
      ...results.of(SearchKind.series),
      ...results.of(SearchKind.podcast),
    ];
    if (podcasts.isNotEmpty) {
      final shown = limited(podcasts, SearchKind.podcast);
      section(AppConstants.podcasts, SearchTab.podcasts, podcasts.length,
          shown.length);
      rows.add(
          (_) => PodcastResults(hits: shown, onOpen: onOpen, scrolling: onAll));
    }

    final sermons = [
      ...results.of(SearchKind.sermon),
      ...results.of(SearchKind.episode),
    ];
    if (sermons.isNotEmpty) {
      final shown = limited(sermons, SearchKind.sermon);
      section(AppConstants.sermonsAndEpisodes, SearchTab.sermons,
          sermons.length, shown.length);
      final queue = [
        for (final h in shown) (h.entry.payload as (PodcastEpisode, String)).$1
      ];
      for (var i = 0; i < shown.length; i++) {
        final show = (shown[i].entry.payload as (PodcastEpisode, String)).$2;
        rows.add((_) => FeedEpisodeRow(
              queue: queue,
              index: i,
              showTitle: show,
              progress: progress,
              currentId: currentId,
              playing: playing,
              overlineLead: show,
            ));
      }
    }

    final videos = [
      ...results.of(SearchKind.playlist),
      ...results.of(SearchKind.video),
    ];
    if (videos.isNotEmpty) {
      final shown = limited(videos, SearchKind.video);
      section(AppConstants.videosSection, SearchTab.videos, videos.length,
          shown.length);
      for (final h in shown) {
        rows.add((_) => VideoResultRow(
            entry: h.entry, onOpen: onOpen, query: results.query));
      }
    }

    final live = results.of(SearchKind.live);
    if (live.isNotEmpty) {
      final shown = limited(live, SearchKind.live);
      section(
          AppConstants.liveSection, SearchTab.live, live.length, shown.length);
      for (final h in shown) {
        rows.add((_) => LiveResultRow(entry: h.entry, onOpen: onOpen));
      }
    }

    rows.add((_) => const SizedBox(height: 24));
    return rows;
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Semantics(
        header: true,
        child: Text(text,
            style: TextStyle(
                color: c.text,
                fontSize: 18,
                height: 24 / 18,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// A network cover, or a tinted block when there is none.
class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final placeholder = ColoredBox(color: c.surface2);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox.square(
        dimension: size,
        child: url.isEmpty
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => placeholder,
                errorWidget: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

/// The one entity that clearly wins: cover, type, title, subtitle, and Play
/// for presenters and series.
class TopResultCard extends StatelessWidget {
  const TopResultCard({super.key, required this.hit, required this.onOpen});

  final SearchHit hit;
  final ValueChanged<SearchEntry> onOpen;

  void _play() {
    final entry = hit.entry;
    switch (entry.kind) {
      case SearchKind.series:
        final (presenter, series) = entry.payload as (Presenter, SermonSeries);
        if (series.parts.isNotEmpty) {
          EpisodePlayback.play(series.parts, 0, showTitle: presenter.name);
        }
      case SearchKind.presenter:
        final presenter = entry.payload as Presenter;
        final latest = presenter.latest;
        if (latest != null) {
          EpisodePlayback.play([latest], 0, showTitle: presenter.name);
        }
      default:
        onOpen(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final e = hit.entry;
    final label = switch (e.kind) {
      SearchKind.presenter => AppConstants.presenterLabel,
      SearchKind.series => AppConstants.seriesLabel,
      _ => AppConstants.podcastLabel,
    };
    final canPlay =
        e.kind == SearchKind.series || e.kind == SearchKind.presenter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onOpen(e),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.line),
            ),
            child: Row(
              children: [
                e.kind == SearchKind.presenter
                    ? PresenterPortrait(name: e.title, image: e.cover, size: 88)
                    : _Cover(url: e.cover, size: 88),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              color: c.text3,
                              fontSize: 11,
                              height: 14 / 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.88)),
                      const SizedBox(height: 3),
                      Text(e.title,
                          style: TextStyle(
                              color: c.text,
                              fontSize: 17,
                              height: 22 / 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(e.subtitle,
                          style: TextStyle(
                              color: c.text2,
                              fontSize: 13,
                              height: 18 / 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (canPlay) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: '${AppConstants.play} ${e.title}',
                    excludeSemantics: true,
                    child: Material(
                      color: c.accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _play,
                        child: SizedBox.square(
                          dimension: 48,
                          child: Icon(Icons.play_arrow_rounded,
                              size: 24, color: c.onAccent),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PresenterResultRow extends StatelessWidget {
  const PresenterResultRow(
      {super.key, required this.hit, required this.onOpen});

  final SearchHit hit;
  final ValueChanged<SearchEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final e = hit.entry;
    final sub = hit.sermonMatches > 0
        ? [
            AppConstants.sermonsMatch(hit.sermonMatches),
            if (e.keywords.isNotEmpty) e.keywords,
          ].join(' · ')
        : e.subtitle;
    return Semantics(
      button: true,
      label: '${e.title}, $sub',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onOpen(e),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
          child: Row(
            children: [
              PresenterPortrait(name: e.title, image: e.cover, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title,
                          style: TextStyle(
                              color: c.text,
                              fontSize: 16,
                              height: 21 / 16,
                              fontWeight: FontWeight.w700)),
                      Text(sub,
                          style: TextStyle(
                              color: c.text2,
                              fontSize: 13,
                              height: 18 / 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 22, color: c.text3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show and series covers, 128 square: a rail on All, a wrapped grid on the
/// Podcasts tab.
class PodcastResults extends StatelessWidget {
  const PodcastResults({
    super.key,
    required this.hits,
    required this.onOpen,
    required this.scrolling,
  });

  final List<SearchHit> hits;
  final ValueChanged<SearchEntry> onOpen;
  final bool scrolling;

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final h in hits) _PodcastCard(entry: h.entry, onOpen: onOpen)
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: scrolling
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    cards[i],
                  ],
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(spacing: 12, runSpacing: 16, children: cards),
            ),
    );
  }
}

class _PodcastCard extends StatelessWidget {
  const _PodcastCard({required this.entry, required this.onOpen});

  final SearchEntry entry;
  final ValueChanged<SearchEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Semantics(
      button: true,
      label: '${entry.title}, ${entry.subtitle}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onOpen(entry),
        child: SizedBox(
          width: 128,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              entry.kind == SearchKind.podcast
                  ? PodcastArt(url: entry.cover, size: 128, radius: 12)
                  : _Cover(url: entry.cover, size: 128),
              const SizedBox(height: 8),
              Text(entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: c.text,
                      fontSize: 14,
                      height: 18 / 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(entry.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: c.text3,
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A video or playlist, as the shared [MediaListRow] (a playlist is stacked)
/// with the searched words marked.
class VideoResultRow extends StatelessWidget {
  const VideoResultRow({
    super.key,
    required this.entry,
    required this.onOpen,
    this.query = '',
  });

  final SearchEntry entry;
  final ValueChanged<SearchEntry> onOpen;
  final String query;

  @override
  Widget build(BuildContext context) {
    final playlist = entry.kind == SearchKind.playlist;
    final length = entry.duration;
    final at = entry.publishedAt;
    return MediaListRow(
      cover: entry.cover,
      title: entry.title,
      details: [
        if (entry.source.isNotEmpty) entry.source,
        if (playlist) '${entry.count} videos',
        if (at != null) MediaListRow.date(at),
      ].join(' · '),
      badge: playlist || length == null ? null : MediaListRow.length(length),
      stacked: playlist,
      query: query,
      onTap: () => onOpen(entry),
    );
  }
}

class LiveResultRow extends StatelessWidget {
  const LiveResultRow({super.key, required this.entry, required this.onOpen});

  final SearchEntry entry;
  final ValueChanged<SearchEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Semantics(
      button: true,
      label: '${entry.title}, ${entry.subtitle}',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onOpen(entry),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _Cover(url: entry.cover, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title,
                        style: TextStyle(
                            color: c.text,
                            fontSize: 15,
                            height: 20 / 15,
                            fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: c.liveDot, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(entry.subtitle,
                            style: TextStyle(
                                color: c.text2,
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(color: c.surface2, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow_rounded, size: 20, color: c.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "No results", and Clear filters when there are filters to clear.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.query,
    required this.hasFilters,
    required this.onClearFilters,
  });

  final String query;
  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 72, 36, 0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration:
                BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
            child: Icon(Icons.search_rounded, size: 34, color: c.accentText),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(AppConstants.noResultsTitle,
                style: TextStyle(
                    fontFamily: 'Newsreader',
                    color: c.text,
                    fontSize: 22,
                    height: 28 / 22,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Text(
              hasFilters
                  ? AppConstants.nothingFor(query)
                  : AppConstants.noMatchFor(query),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: c.text2,
                  fontSize: 14,
                  height: 21 / 14,
                  fontWeight: FontWeight.w400)),
          if (hasFilters) ...[
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onClearFilters,
              style: FilledButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: c.onAccent,
                minimumSize: const Size(44, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: const StadiumBorder(),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: const Text(AppConstants.clearFilters),
            ),
          ],
        ],
      ),
    );
  }
}
