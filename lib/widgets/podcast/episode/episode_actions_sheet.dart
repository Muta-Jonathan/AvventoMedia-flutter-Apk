import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/app_constants.dart';
import '../../../components/utils.dart';
import '../../../controller/download_controller.dart';
import '../../../controller/episode_progress_controller.dart';
import '../../../controller/library_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../../../models/saved_item_model.dart';
import '../../common/save_bottom_sheet.dart';
import '../../../themes/avvento_colors.dart';

/// The ⋯ menu for an episode: save to library, share, add to playlist,
/// download and played state.
class EpisodeActionsSheet {
  static Future<void> show(BuildContext context, PodcastEpisode episode,
      {required String showTitle}) {
    final c = Theme.of(context).avvento;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final downloads = Get.find<DownloadController>();
        final progress = Get.find<EpisodeProgressController>();
        final id = episode.id;
        final played = progress.isPlayed(id);
        final library = Get.find<LibraryController>();
        final inLibrary = library.isFavorite(id);
        final saved = SavedItem(
          id: id,
          type: 'podcast_episode',
          title: episode.title,
          thumbnailUrl: episode.art,
          groupId: episode.playlistMediaAlbum,
          groupTitle: showTitle,
          url: episode.downloadLink,
          description: episode.description,
          publishedAtItem:
              DateTime.fromMillisecondsSinceEpoch(episode.publishedAt * 1000)
                  .toIso8601String(),
          savedAt: DateTime.now(),
        );

        Widget action(IconData icon, String label, VoidCallback onTap) =>
            ListTile(
              minTileHeight: 52,
              leading: Icon(icon, color: c.text),
              title: Text(label,
                  style: TextStyle(
                      color: c.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(sheetContext);
                onTap();
              },
            );

        return SafeArea(
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(showTitle.toUpperCase(),
                        style: TextStyle(
                            color: c.text3,
                            fontSize: 11,
                            height: 14 / 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.66)),
                    const SizedBox(height: 4),
                    Text(episode.title,
                        style: TextStyle(
                            color: c.text,
                            fontSize: 16,
                            height: 21 / 16,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              action(
                inLibrary
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                inLibrary
                    ? AppConstants.removeFromLibrary
                    : AppConstants.saveToLibrary,
                () => library.toggleFavorite(saved),
              ),
              if (episode.publicLink.isNotEmpty)
                action(
                    Icons.ios_share_rounded,
                    AppConstants.share,
                    () =>
                        Utils.share('${episode.title}\n${episode.publicLink}')),
              action(Icons.playlist_add_rounded, AppConstants.addToPlaylist,
                  () => SaveBottomSheet.show(context, saved)),
              if (downloads.isFailed(id)) ...[
                action(Icons.refresh_rounded, AppConstants.retryDownload,
                    () => downloads.retry(id)),
                action(Icons.close_rounded, AppConstants.cancelDownload,
                    () => downloads.cancel(id)),
              ] else if (downloads.isQueued(id))
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
              const SizedBox(height: 8),
            ],
          )),
        );
      },
    );
  }
}
