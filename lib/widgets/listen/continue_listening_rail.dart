import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../components/episode_playback.dart';
import '../../controller/connectivity_controller.dart';
import '../../controller/download_controller.dart';
import '../../controller/episode_progress_controller.dart';
import '../../themes/avvento_colors.dart';
import '../podcast/podcast_palette.dart';
import 'section_header.dart';

/// Episodes you stopped part-way, most recent first, with a progress bar and
/// "14 min left". Hidden when there are none.
class ContinueListeningRail extends StatelessWidget {
  const ContinueListeningRail({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final controller = Get.find<EpisodeProgressController>();

    return Obx(() {
      final offline = ConnectivityController.isOffline;
      final downloads = Get.find<DownloadController>();
      // Offline, only what's on the device can play.
      final items = [
        for (final r in controller.continueListening)
          if (!offline || downloads.isDownloaded(r.episode.id)) r
      ];
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListenSectionHeader(
              title: AppConstants.continueListening,
              padding: EdgeInsets.fromLTRB(20, 22, 20, 8)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final r in items) ...[
                  if (r != items.first) const SizedBox(width: 10),
                  _Card(recent: r, progress: controller.of(r.episode.id), c: c),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.recent, required this.progress, required this.c});

  final RecentEpisode recent;
  final EpisodeProgress progress;
  final AvventoColors c;

  @override
  Widget build(BuildContext context) {
    final e = recent.episode;
    final left = progress.remaining;
    final minutes = left == null ? null : (left.inSeconds / 60).ceil();
    final leftLabel = minutes == null ? null : AppConstants.minLeft(minutes);

    return Semantics(
      button: true,
      label: [
        AppConstants.resume,
        e.title,
        if (recent.showTitle.isNotEmpty) recent.showTitle,
        if (left != null) AppConstants.timeLeftSemantics(left),
      ].join(', '),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            EpisodePlayback.toggle([e], 0, showTitle: recent.showTitle),
        child: Container(
          width: 272,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              PodcastArt(url: e.art, size: 60, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: c.text,
                            fontSize: 14,
                            height: 19 / 14,
                            fontWeight: FontWeight.w700)),
                    if (recent.showTitle.isNotEmpty)
                      Text(recent.showTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: c.text3,
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress.fraction,
                              minHeight: 3,
                              backgroundColor: c.surface2,
                              color: c.accent,
                            ),
                          ),
                        ),
                        if (leftLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(leftLabel,
                              style: TextStyle(
                                  color: c.text2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
