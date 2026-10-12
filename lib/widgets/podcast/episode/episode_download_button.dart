import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_constants.dart';
import '../../../controller/download_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../podcast_palette.dart';

/// Download arrow → progress ring (tap to cancel) → amber tick.
/// Tapping the tick calls [onDownloaded] (e.g. to offer removal).
class EpisodeDownloadButton extends StatelessWidget {
  const EpisodeDownloadButton({
    super.key,
    required this.episode,
    required this.showTitle,
    this.onDownloaded,
  });

  final PodcastEpisode episode;
  final String showTitle;
  final VoidCallback? onDownloaded;

  @override
  Widget build(BuildContext context) {
    final downloads = Get.find<DownloadController>();
    final palette = PodcastPalette(context);
    final id = episode.id;

    return Obx(() {
      final task = downloads.tasks[id];
      if (task != null) {
        final running = task.status == DownloadStatus.downloading;
        return _Tap(
          label: AppConstants.cancelDownload,
          onTap: () => downloads.cancel(id),
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                // Spins while the size is unknown.
                value: running ? task.fraction : (task.fraction ?? 0),
                strokeWidth: 2,
                color: running ? PodcastPalette.accent : palette.muted,
                backgroundColor: palette.track,
              ),
            ),
            Icon(
                task.status == DownloadStatus.waitingForWifi
                    ? Icons.wifi_rounded
                    : Icons.stop_rounded,
                size: 11,
                color: palette.muted),
          ]),
        );
      }
      if (downloads.isDownloaded(id)) {
        return _Tap(
          label: AppConstants.removeDownload,
          onTap: onDownloaded,
          child: const Icon(Icons.download_done_rounded,
              size: 22, color: PodcastPalette.accent),
        );
      }
      return _Tap(
        label: AppConstants.download,
        onTap: () => downloads.download(episode, showTitle: showTitle),
        child: Icon(Icons.download_rounded, size: 22, color: palette.muted),
      );
    });
  }
}

class _Tap extends StatelessWidget {
  const _Tap({required this.label, required this.child, this.onTap});

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: SizedBox(width: 40, height: 40, child: Center(child: child)),
        ),
      );
}
