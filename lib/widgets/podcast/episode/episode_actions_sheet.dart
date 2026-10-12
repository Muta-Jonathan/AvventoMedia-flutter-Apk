import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_constants.dart';
import '../../../components/utils.dart';
import '../../../controller/download_controller.dart';
import '../../../controller/episode_progress_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../podcast_palette.dart';

/// The ⋯ menu for an episode: download, played state and share.
class EpisodeActionsSheet {
  static Future<void> show(BuildContext context, PodcastEpisode episode,
      {required String showTitle}) {
    final palette = PodcastPalette(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: palette.sheet,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        final downloads = Get.find<DownloadController>();
        final progress = Get.find<EpisodeProgressController>();
        final id = episode.id;
        final played = progress.isPlayed(id);

        Widget action(IconData icon, String label, VoidCallback onTap) =>
            ListTile(
              leading: Icon(icon, color: palette.title),
              title: Text(label, style: TextStyle(color: palette.title)),
              onTap: () {
                Navigator.pop(sheetContext);
                onTap();
              },
            );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  episode.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: palette.title,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              if (downloads.isQueued(id))
                action(Icons.close_rounded, AppConstants.cancelDownload,
                    () => downloads.cancel(id))
              else if (downloads.isDownloaded(id))
                action(Icons.delete_outline_rounded,
                    AppConstants.removeDownload, () => downloads.remove(id))
              else
                action(Icons.download_rounded, AppConstants.download,
                    () => downloads.download(episode, showTitle: showTitle)),
              action(
                played
                    ? Icons.radio_button_unchecked_rounded
                    : Icons.check_circle_outline_rounded,
                played ? AppConstants.markUnplayed : AppConstants.markPlayed,
                () => progress.setPlayed(id, !played),
              ),
              if (episode.publicLink.isNotEmpty)
                action(
                    Icons.share_rounded,
                    AppConstants.share,
                    () =>
                        Utils.share('${episode.title}\n${episode.publicLink}')),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
