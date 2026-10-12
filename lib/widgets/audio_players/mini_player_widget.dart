import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../components/app_constants.dart';
import '../../controller/audio_player_controller.dart';
import '../../controller/download_controller.dart';

/// The collapsed mini-player bar. No Positioned wrapper — it is placed
/// inside the PlayerPanel builder in main.dart.
class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioPlayerController controller = Get.find<AudioPlayerController>();

    return Obx(() {
      final mediaItem = controller.currentMediaItemRx.value;
      final isLive = controller.isLive.value;
      if (mediaItem == null) return const SizedBox.shrink();

      return StreamBuilder<PlayerState>(
        stream: controller.audioPlayer.playerStateStream,
        initialData: controller.audioPlayer.playerState,
        builder: (context, snapshot) {
          final state = snapshot.data;
          // just_audio keeps playing == true after the track completes.
          final isCompleted =
              state?.processingState == ProcessingState.completed;
          final isPlaying = (state?.playing ?? false) && !isCompleted;
          final isBuffering =
              state?.processingState == ProcessingState.buffering ||
                  state?.processingState == ProcessingState.loading;

          return _buildMiniPlayerBar(
              context, controller, mediaItem, isLive, isPlaying, isBuffering,
              isCompleted);
        },
      );
    });
  }

  Widget _buildMiniPlayerBar(
    BuildContext context,
    AudioPlayerController controller,
    MediaItem mediaItem,
    bool isLive,
    bool isPlaying,
    bool isBuffering,
    bool isCompleted,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final artUri = mediaItem.artUri?.toString();
    // Downloaded episodes play from the device.
    final offline = !isLive &&
        Get.isRegistered<DownloadController>() &&
        Get.find<DownloadController>().isDownloaded(mediaItem.id);

    final bar = GestureDetector(
      onTap: () {
        // Expand the panel to full screen
        controller.panelController.expand();
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.secondary,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main content row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  // Artwork thumbnail
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: artUri != null
                          ? CachedNetworkImage(
                              imageUrl: artUri,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: colorScheme.surface,
                                child: Icon(
                                  CupertinoIcons.music_note_2,
                                  color: colorScheme.onSecondary,
                                  size: 18,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: colorScheme.surface,
                                child: Icon(
                                  CupertinoIcons.music_note_2,
                                  color: colorScheme.onSecondary,
                                  size: 18,
                                ),
                              ),
                            )
                          : Container(
                              color: colorScheme.surface,
                              child: Icon(
                                CupertinoIcons.music_note_2,
                                color: colorScheme.onSecondary,
                                size: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + subtitle row
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mediaItem.title,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (isLive) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.redAccent.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons
                                          .antenna_radiowaves_left_right,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 8,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (offline) ...[
                              const Icon(Icons.download_rounded,
                                  size: 12, color: Color(0xFFFFCA28)),
                              const SizedBox(width: 3),
                            ],
                            Flexible(
                              child: Text(
                                offline
                                    ? AppConstants.playingOffline
                                    : mediaItem.artist ??
                                        (isLive ? 'Live Radio' : 'Podcast'),
                                style: TextStyle(
                                  color: colorScheme.onSecondary,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // IconButton gives a 48dp tap area. Semantics instead of
                  // tooltip: there is no Overlay above the mini bar.
                  Semantics(
                    label: isCompleted
                        ? 'Replay'
                        : (isPlaying ? 'Pause' : 'Play'),
                    child: IconButton(
                      // No padding: default 8px padding overflowed the 70px
                      // bar. Tap target stays 48dp.
                      padding: EdgeInsets.zero,
                      onPressed: isCompleted
                          ? controller.replay
                          : (isPlaying ? controller.pause : controller.play),
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!isLive) _progressRing(controller, colorScheme),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary,
                              shape: BoxShape.circle,
                            ),
                            child: isBuffering
                                ? Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onTertiary,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : Icon(
                                    isCompleted
                                        ? CupertinoIcons.arrow_counterclockwise
                                        : isPlaying
                                            ? CupertinoIcons.pause_fill
                                            : CupertinoIcons.play_fill,
                                    color: colorScheme.onTertiary,
                                    size: 16,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Close player',
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.closeMiniPlayer,
                      icon: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: colorScheme.onSecondary,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(button: true, label: 'Open player', child: bar);
  }

  /// Podcast progress drawn as a ring around the play/pause button.
  Widget _progressRing(
      AudioPlayerController controller, ColorScheme colorScheme) {
    return StreamBuilder<Duration>(
      stream: controller.audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = controller.audioPlayer.duration ?? Duration.zero;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

        return SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            backgroundColor: colorScheme.surface.withValues(alpha: 0.3),
            color: colorScheme.tertiary,
          ),
        );
      },
    );
  }
}
