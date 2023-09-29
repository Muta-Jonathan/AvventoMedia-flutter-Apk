import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  const Controls({super.key, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;
          if (!(playing ?? false)) {
            return IconButton(
                onPressed: audioPlayer.play,
              color: Colors.white,
                icon: const Icon(CupertinoIcons.play_fill),
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
                onPressed: audioPlayer.pause,
              color: Colors.white,
                icon: const Icon(CupertinoIcons.pause_fill),
            );
          } else if (processingState == ProcessingState.completed) {
            return IconButton(
              onPressed: audioPlayer.play,
              color: Colors.white,
              icon: const Icon(CupertinoIcons.arrow_counterclockwise_circle_fill),
            );
          }
          return IconButton(
            onPressed: audioPlayer.play,
            color: Colors.white,
            icon: const Icon(CupertinoIcons.exclamationmark_circle_fill),
          );
        }
    );
  }
}
