import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../components/app_constants.dart';
import '../../controller/audio_player_controller.dart';
import '../../controller/download_controller.dart';
import '../../themes/avvento_colors.dart';

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
      // Read here: Obx doesn't see reads inside the stream builder below.
      final canNext = controller.hasNext.value;
      final canPrevious = controller.hasPrevious.value;
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

          return _buildMiniPlayerBar(context, controller, mediaItem, isLive,
              isPlaying, isBuffering, isCompleted, canNext, canPrevious);
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
    bool canNext,
    bool canPrevious,
  ) {
    final c = Theme.of(context).avvento;
    final artUri = mediaItem.artUri?.toString();
    // Downloaded episodes play from the device.
    final offline = !isLive &&
        Get.isRegistered<DownloadController>() &&
        Get.find<DownloadController>().isDownloaded(mediaItem.id);

    Widget art() {
      final placeholder = ColoredBox(
        color: c.surface2,
        child: Icon(CupertinoIcons.music_note_2, color: c.text3, size: 18),
      );
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox.square(
          dimension: 44,
          child: artUri == null
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: artUri,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => placeholder,
                  errorWidget: (_, __, ___) => placeholder,
                ),
        ),
      );
    }

    Widget subtitle() {
      final style = TextStyle(color: c.text2, fontSize: 12, height: 16 / 12);
      if (isLive) {
        return Row(
          children: [
            Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: c.liveDot, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(AppConstants.liveSubtitle,
                  style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        );
      }
      return Row(
        children: [
          if (offline) ...[
            Icon(Icons.download_rounded, size: 12, color: c.accentText),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
                offline
                    ? AppConstants.playingOffline
                    : mediaItem.artist ?? 'Podcast',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    // Episodes skip back and forward through their queue; the radio has
    // nothing to skip, so it keeps a close button instead.

    Widget skip(String label, IconData icon, VoidCallback? onTap) => Semantics(
          button: true,
          enabled: onTap != null,
          label: label,
          excludeSemantics: true,
          child: SizedBox.square(
            dimension: 44,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onTap,
              icon:
                  Icon(icon, size: 20, color: onTap != null ? c.text : c.text3),
            ),
          ),
        );

    final card = DecoratedBox(
        // It floats, so it casts its own soft shadow.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x2E000000), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Material(
          color: c.mini,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.line),
            ),
            child: Stack(
              children: [
                InkWell(
                  onTap: controller.panelController.expand,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 2, 0),
                    child: Row(
                      children: [
                        ExcludeSemantics(child: art()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mediaItem.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: c.text,
                                      fontSize: 14,
                                      height: 19 / 14,
                                      fontWeight: FontWeight.w700)),
                              subtitle(),
                            ],
                          ),
                        ),
                        if (!isLive)
                          skip(
                              AppConstants.previous,
                              CupertinoIcons.backward_fill,
                              canPrevious ? controller.playPrevious : null),
                        _PlayButton(
                          controller: controller,
                          isPlaying: isPlaying,
                          isBuffering: isBuffering,
                          isCompleted: isCompleted,
                        ),
                        if (!isLive)
                          skip(AppConstants.next, CupertinoIcons.forward_fill,
                              canNext ? controller.playNext : null)
                        else
                          Semantics(
                            button: true,
                            label: 'Close player',
                            excludeSemantics: true,
                            child: SizedBox.square(
                              dimension: 44,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: controller.closeMiniPlayer,
                                icon: Icon(CupertinoIcons.xmark,
                                    size: 14, color: c.text3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isLive)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _progressLine(controller, c),
                  ),
              ],
            ),
          ),
        ));

    // 64 tall, 8 from the sides and from whatever is below. Swipe it
    // sideways to close the player.
    return Semantics(
      container: true,
      label: '${AppConstants.openPlayer}, ${mediaItem.title}',
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Close player'):
            controller.closeMiniPlayer,
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Dismissible(
          key: const ValueKey('mini-player'),
          onDismissed: (_) => controller.closeMiniPlayer(),
          child: card,
        ),
      ),
    );
  }

  /// Podcast progress: a 2dp line along the bottom edge.
  Widget _progressLine(AudioPlayerController controller, AvventoColors c) {
    return StreamBuilder<Duration>(
      stream: controller.audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = controller.audioPlayer.duration ?? Duration.zero;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;
        return ExcludeSemantics(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 2,
            backgroundColor: c.surface2,
            color: c.accent,
          ),
        );
      },
    );
  }
}

/// The round accent Play / Pause / Replay button; a 44dp target.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.controller,
    required this.isPlaying,
    required this.isBuffering,
    required this.isCompleted,
  });

  final AudioPlayerController controller;
  final bool isPlaying;
  final bool isBuffering;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Semantics(
      button: true,
      label: isCompleted ? 'Replay' : (isPlaying ? 'Pause' : 'Play'),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 44,
        child: Center(
          child: Material(
            color: c.accent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isCompleted
                  ? controller.replay
                  : (isPlaying ? controller.pause : controller.play),
              child: SizedBox.square(
                dimension: 40,
                child: isBuffering
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                            color: c.onAccent, strokeWidth: 2),
                      )
                    : Icon(
                        isCompleted
                            ? CupertinoIcons.arrow_counterclockwise
                            : isPlaying
                                ? CupertinoIcons.pause_fill
                                : CupertinoIcons.play_fill,
                        color: c.onAccent,
                        size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
