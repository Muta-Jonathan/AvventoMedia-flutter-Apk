import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/episode_playback.dart';
import '../../../controller/connectivity_controller.dart';
import '../../../controller/download_controller.dart';
import '../../../controller/episode_progress_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import 'episode_actions_sheet.dart';
import 'episode_download_button.dart';
import 'episode_feed_tile.dart';

/// An [EpisodeFeedTile] wired up for a feed: `queue[index]` plays with
/// [queue] as the up-next list, and it shows the download state, the ⋯
/// sheet and the offline style. Shared by podcast and presenter pages.
class FeedEpisodeRow extends StatelessWidget {
  const FeedEpisodeRow({
    super.key,
    required this.queue,
    required this.index,
    required this.showTitle,
    required this.progress,
    required this.currentId,
    required this.playing,
    this.title,
    this.overlineLead,
    this.showSummary = true,
    this.horizontalMargin = 20,
  });

  final List<PodcastEpisode> queue;
  final int index;

  /// Saved with downloads and shown in the ⋯ sheet.
  final String showTitle;
  final Map<String, EpisodeProgress> progress;
  final String? currentId;
  final bool playing;
  final String? title;
  final String? overlineLead;
  final bool showSummary;
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    final episode = queue[index];
    final isCurrent = episode.id == currentId;
    final downloads = Get.find<DownloadController>();
    void more() =>
        EpisodeActionsSheet.show(context, episode, showTitle: showTitle);

    return Obx(() {
      // Read both so Obx always has something to watch.
      final downloaded = downloads.isDownloaded(episode.id);
      final offline = Get.isRegistered<ConnectivityController>() &&
          Get.find<ConnectivityController>().offline.value;
      return EpisodeFeedTile(
        episode: episode,
        title: title,
        showSummary: showSummary,
        progress: progress[episode.id] ?? const EpisodeProgress(),
        isCurrent: isCurrent,
        isPlaying: isCurrent && playing,
        available: !offline || downloaded,
        overlineLead: overlineLead,
        horizontalMargin: horizontalMargin,
        onTap: () => EpisodePlayback.open(queue, index),
        onPlayTap: () => EpisodePlayback.toggle(queue, index),
        onMore: more,
        downloadLabel: EpisodeDownloadLabel(episodeId: episode.id),
        download: EpisodeDownloadButton(
            episode: episode, showTitle: showTitle, onDownloaded: more),
      );
    });
  }
}
