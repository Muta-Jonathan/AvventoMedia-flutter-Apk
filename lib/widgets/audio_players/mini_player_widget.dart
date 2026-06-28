import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../controller/audio_player_controller.dart';
import '../../routes/routes.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioPlayerController controller = Get.find<AudioPlayerController>();

    return Obx(() {
      final isActive = controller.isPlayerActive.value;
      final isVisible = controller.isMiniPlayerVisible.value;

      if (!isActive || !isVisible) return const SizedBox.shrink();

      return StreamBuilder<PlayerState>(
        stream: controller.audioPlayer.playerStateStream,
        initialData: controller.audioPlayer.playerState,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final isPlaying = state?.playing ?? false;
          final isBuffering = state?.processingState == ProcessingState.buffering || state?.processingState == ProcessingState.loading;

          return _buildFloatingMiniPlayer(context, controller, isPlaying, isBuffering);
        },
      );
    });
  }

  Widget _buildFloatingMiniPlayer(
    BuildContext context,
    AudioPlayerController controller,
    bool isPlaying,
    bool isBuffering,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaItem = controller.currentMediaItem!;
    final isLive = controller.isLive.value;
    final artUri = mediaItem.artUri?.toString();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // If on main tab page (has nav bar), offset above it; otherwise near bottom
    final isTabPage = Get.currentRoute == '/' || Get.currentRoute == Routes.home;
    final bottomOffset = isTabPage
        ? kBottomNavigationBarHeight + bottomPadding + 6
        : bottomPadding + 10;

    return Positioned(
      left: 10,
      right: 10,
      bottom: bottomOffset,
      child: GestureDetector(
        onTap: () {
          if (isLive) {
            Get.toNamed(Routes.getOnlineRadioRoute());
          } else {
            Get.toNamed(Routes.getPodcastRoute());
          }
        },
        child: Dismissible(
          key: const Key('mini_player_dismissible'),
          direction: DismissDirection.down,
          onDismissed: (_) {
            controller.closeMiniPlayer();
          },
          child: Material(
          type: MaterialType.transparency,
          child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colorScheme.secondary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main content row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                    color: Colors.redAccent.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.antenna_radiowaves_left_right,
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
                                  mediaItem.artist ?? (isLive ? 'Live Radio' : 'Podcast'),
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

                    // Previous Button
                    if (!isLive)
                      GestureDetector(
                        onTap: controller.hasPrevious.value ? controller.playPrevious : null,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            CupertinoIcons.backward_fill,
                            color: controller.hasPrevious.value ? colorScheme.onPrimary : Colors.grey.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ),
                      ),

                    // Play/Pause button
                    GestureDetector(
                      onTap: () {
                        if (isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      },
                      child: Container(
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
                    const SizedBox(width: 8),

                    // Next Button
                    if (!isLive)
                      GestureDetector(
                        onTap: controller.hasNext.value ? controller.playNext : null,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                          child: Icon(
                            CupertinoIcons.forward_fill,
                            color: controller.hasNext.value ? colorScheme.onPrimary : Colors.grey.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ),
                      ),

                    // Close (dismiss) button
                    GestureDetector(
                      onTap: () => controller.closeMiniPlayer(),
                      child: Container(
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
                  ],
                ),
              ), // End Padding
              
              // Progress bar for podcasts (moved to bottom)
              if (!isLive)
                StreamBuilder<Duration>(
                  stream: controller.audioPlayer.positionStream,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    final duration = controller.audioPlayer.duration ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                        : 0.0;

                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2.5,
                        backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                      ),
                    );
                  },
                ),
            ],
          ), // End Column
          ), // End Container
        ), // End Material
        ), // End Dismissible
      ), // End GestureDetector
    ); // End Positioned
  }
}
