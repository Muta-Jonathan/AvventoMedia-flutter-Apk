import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_constants.dart';
import '../../../controller/download_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../../../themes/avvento_colors.dart';
import 'episode_download_button.dart';

/// Download all as a circle: arrow → progress ring (tap to cancel) →
/// check (tap to remove, after asking). The ring covers all [episodes].
class DownloadAllButton extends StatelessWidget {
  const DownloadAllButton({
    super.key,
    required this.episodes,
    required this.showTitle,
    this.dimension = 48,
  });

  final List<PodcastEpisode> episodes;

  /// Saved with each download, e.g. the show or series title.
  final String showTitle;

  /// 48 in page headers, 44 on series cards.
  final double dimension;

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
            child: SizedBox.square(
                dimension: dimension, child: Center(child: icon)),
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
