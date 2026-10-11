import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:miniplayer/miniplayer.dart';

import '../../controller/audio_player_controller.dart';

/// The collapsed mini-player bar. No Positioned wrapper — it is placed
/// inside the Miniplayer builder by nav_bar.dart.
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
          final isPlaying = state?.playing ?? false;
          final isBuffering =
              state?.processingState == ProcessingState.buffering ||
                  state?.processingState == ProcessingState.loading;

          return _buildMiniPlayerBar(
              context, controller, mediaItem, isLive, isPlaying, isBuffering);
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
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final artUri = mediaItem.artUri?.toString();

    final bar = GestureDetector(
      onTap: () {
        // Expand the Miniplayer panel to full screen
        controller.miniplayerController.animateToHeight(state: PanelState.MAX);
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
                            Flexible(
                              child: Text(
                                mediaItem.artist ??
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
                    label: isPlaying ? 'Pause' : 'Play',
                    child: IconButton(
                      onPressed: isPlaying ? controller.pause : controller.play,
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: isBuffering
                            ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Icon(
                                isPlaying
                                    ? CupertinoIcons.pause_fill
                                    : CupertinoIcons.play_fill,
                                color: Colors.black,
                                size: 16,
                              ),
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Close player',
                    child: IconButton(
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

            // Progress bar for podcasts (at bottom of mini bar)
            if (!isLive)
              StreamBuilder<Duration>(
                stream: controller.audioPlayer.positionStream,
                builder: (context, posSnapshot) {
                  final position = posSnapshot.data ?? Duration.zero;
                  final duration =
                      controller.audioPlayer.duration ?? Duration.zero;
                  final progress = duration.inMilliseconds > 0
                      ? (position.inMilliseconds / duration.inMilliseconds)
                          .clamp(0.0, 1.0)
                      : 0.0;

                  return LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    borderRadius: BorderRadius.zero,
                    backgroundColor: colorScheme.surface.withValues(alpha: 0.3),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                  );
                },
              ),
          ],
        ),
      ),
    );

    return Semantics(button: true, label: 'Open player', child: bar);
  }
}
