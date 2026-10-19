import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../components/app_constants.dart';
import '../../components/feed_kind.dart';
import '../../controller/podcast_controller.dart';
import '../../models/radiomodel/radio_podcast_model.dart';
import '../../routes/routes.dart';
import '../../themes/avvento_colors.dart';
import '../podcast/podcast_palette.dart';
import '../providers/radio_podcast_provider.dart';
import 'inline_notice.dart';
import 'section_header.dart';

/// "Podcasts" with two rails: Series & Bible (play in order) and Daily &
/// weekly shows (newest first). Hidden until the shows load.
class PodcastRails extends StatelessWidget {
  const PodcastRails({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RadioPodcastProvider>();
    final shows = provider.podcasts;
    if (shows.isEmpty) {
      if (!provider.failed) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListenSectionHeader(title: AppConstants.podcasts),
          InlineNotice(
              message: AppConstants.podcastsLoadFailed,
              actionLabel: AppConstants.retry,
              onAction: provider.fetchAllPodcasts),
        ],
      );
    }

    final inOrder = [
      for (final s in shows)
        if (playsInOrderByTitle(s.title)) s
    ];
    final daily = [
      for (final s in shows)
        if (!playsInOrderByTitle(s.title)) s
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenSectionHeader(
          title: AppConstants.podcasts,
          action: AppConstants.seeAllCount(shows.length),
          onAction: () => Get.toNamed(Routes.getPodcastListRoute()),
        ),
        if (inOrder.isNotEmpty)
          _Rail(
              title: AppConstants.seriesAndBible,
              tag: AppConstants.playsInOrder,
              shows: inOrder),
        if (daily.isNotEmpty)
          _Rail(
              title: AppConstants.dailyAndWeekly,
              tag: AppConstants.newestFirstTag,
              shows: daily),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.title, required this.tag, required this.shows});

  final String title;
  final String tag;
  final List<RadioPodcast> shows;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Row(
            children: [
              Flexible(
                child: Semantics(
                  header: true,
                  child: Text(title,
                      style: TextStyle(
                          color: c.text,
                          fontSize: 15,
                          height: 20 / 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: c.surface2, borderRadius: BorderRadius.circular(11)),
                child: Text(tag,
                    style: TextStyle(
                        color: c.text2,
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in shows) ...[
                if (s != shows.first) const SizedBox(width: 12),
                _ShowCard(show: s),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShowCard extends StatelessWidget {
  const _ShowCard({required this.show});

  final RadioPodcast show;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Semantics(
      button: true,
      label: '${show.title}, ${AppConstants.episodeCount(show.episodes)}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.find<PodcastController>().setSelectedEpisode(show);
          Get.toNamed(Routes.getPodcastEpisodeListRoute());
        },
        child: SizedBox(
          width: 136,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PodcastArt(url: show.art, size: 136, radius: 12),
              const SizedBox(height: 8),
              Text(show.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: c.text,
                      fontSize: 14,
                      height: 18 / 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(AppConstants.episodeCount(show.episodes),
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
