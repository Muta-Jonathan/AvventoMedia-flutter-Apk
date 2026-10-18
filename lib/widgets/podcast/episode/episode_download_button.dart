import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_constants.dart';
import '../../../controller/download_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../../../themes/avvento_colors.dart';

/// Download arrow → dashed ring (queued) → progress ring with stop (tap to
/// cancel) → accent check. Failed shows retry. Tapping the check calls
/// [onDownloaded] (e.g. to offer removal).
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
    final c = Theme.of(context).avvento;
    final id = episode.id;

    return Obx(() {
      final task = downloads.tasks[id];
      if (task != null) {
        return switch (task.status) {
          DownloadStatus.failed => _Tap(
              label: AppConstants.retryDownload,
              onTap: () => downloads.retry(id),
              child: Icon(Icons.refresh_rounded, size: 22, color: c.liveText),
            ),
          DownloadStatus.downloading => _Tap(
              label: AppConstants.cancelDownload,
              onTap: () => downloads.cancel(id),
              child: DownloadRing(fraction: task.fraction),
            ),
          _ => _Tap(
              label: AppConstants.cancelDownload,
              onTap: () => downloads.cancel(id),
              child: CustomPaint(
                size: const Size.square(24),
                painter: _DashedRing(c.text3),
                child: SizedBox.square(
                  dimension: 24,
                  child: Center(
                    child: switch (task.status) {
                      DownloadStatus.waitingForWifi =>
                        Icon(Icons.wifi_rounded, size: 11, color: c.text3),
                      DownloadStatus.paused =>
                        Icon(Icons.pause_rounded, size: 11, color: c.text3),
                      _ => Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                              color: c.text3, shape: BoxShape.circle),
                        ),
                    },
                  ),
                ),
              ),
            ),
        };
      }
      if (downloads.isDownloaded(id)) {
        return _Tap(
          label: AppConstants.removeDownload,
          onTap: onDownloaded,
          child: const DownloadDoneBadge(),
        );
      }
      return _Tap(
        label: AppConstants.download,
        onTap: () => downloads.download(episode, showTitle: showTitle),
        child: Icon(Icons.download_rounded, size: 22, color: c.text3),
      );
    });
  }
}

/// 26 ring with a stop square; spins while the size is unknown.
class DownloadRing extends StatelessWidget {
  const DownloadRing({super.key, required this.fraction});

  final double? fraction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return SizedBox.square(
      dimension: 26,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox.square(
          dimension: 26,
          child: CircularProgressIndicator(
            value: fraction,
            strokeWidth: 2.5,
            color: c.accent,
            backgroundColor: c.surface2,
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: c.accent, borderRadius: BorderRadius.circular(2)),
        ),
      ]),
    );
  }
}

/// Filled accent circle with a check.
class DownloadDoneBadge extends StatelessWidget {
  const DownloadDoneBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
      child: Icon(Icons.check_rounded, size: 16, color: c.onAccent),
    );
  }
}

/// "Queued", "42%", "Downloaded" or "Failed" beside the play pill; empty
/// when the episode isn't downloaded or queued.
class EpisodeDownloadLabel extends StatelessWidget {
  const EpisodeDownloadLabel({super.key, required this.episodeId});

  final String episodeId;

  @override
  Widget build(BuildContext context) {
    final downloads = Get.find<DownloadController>();
    final c = Theme.of(context).avvento;

    return Obx(() {
      final task = downloads.tasks[episodeId];
      final downloaded = downloads.isDownloaded(episodeId);
      final String? text = switch (task?.status) {
        null => downloaded ? AppConstants.downloadedLabel : null,
        DownloadStatus.downloading => task!.fraction == null
            ? AppConstants.downloading
            : AppConstants.percent(task.fraction!),
        DownloadStatus.waiting => AppConstants.queued,
        DownloadStatus.waitingForWifi => AppConstants.waitingForWifiShort,
        DownloadStatus.paused => AppConstants.paused,
        DownloadStatus.failed => AppConstants.failed,
      };
      if (text == null) return const SizedBox.shrink();
      return ExcludeSemantics(
        child: Text(
          text,
          style: TextStyle(
            color: task == null
                ? c.accentText
                : task.status == DownloadStatus.failed
                    ? c.liveText
                    : c.text3,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}

class _DashedRing extends CustomPainter {
  _DashedRing(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashes = 12;
    const sweep = 2 * math.pi / dashes;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rect = (Offset.zero & size).deflate(1);
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => old.color != color;
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
          child: SizedBox(width: 44, height: 44, child: Center(child: child)),
        ),
      );
}
