import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../controller/audio_player_controller.dart';
import '../../controller/episode_progress_controller.dart';

/// Rebuilds with the loaded episode id, whether it is playing, and saved
/// episode progress.
class PlayerStateBuilder extends StatelessWidget {
  const PlayerStateBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, String? currentId, bool playing,
      Map<String, EpisodeProgress> progress) builder;

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerController>();
    final progressController = Get.find<EpisodeProgressController>();

    return Obx(() {
      final currentId =
          audio.isLive.value ? null : audio.currentMediaItemRx.value?.id;
      // Snapshot so lazily built rows use what this Obx subscribed to.
      final progress = Map.of(progressController.progress);
      return StreamBuilder<PlayerState>(
        stream: audio.audioPlayer.playerStateStream,
        initialData: audio.audioPlayer.playerState,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final playing = state != null &&
              state.playing &&
              state.processingState != ProcessingState.completed;
          return builder(context, currentId, playing, progress);
        },
      );
    });
  }
}
