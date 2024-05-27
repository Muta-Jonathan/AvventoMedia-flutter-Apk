import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../controller/audio_player_controller.dart';

class Controls extends StatefulWidget {
  final AudioPlayerController audioPlayerController;

  const Controls({super.key, required this.audioPlayerController});

  @override
  ControlsState createState() => ControlsState();
}

class ControlsState extends State<Controls> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    widget.audioPlayerController.audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        if(mounted) {
          _controller.forward();
        }
      } else {
        if(mounted) {
          _controller.reverse();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.isCompleted) {
          widget.audioPlayerController.pause();
        } else {
          widget.audioPlayerController.play();
        }
      },
      child: Container(
        width: 60.0, // Adjust the size as needed
        height: 60.0, // Adjust the size as needed
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.redAccent, // Customize the background color
        ),
        child: Align(
          alignment: Alignment.center,
          child:    widget.audioPlayerController.audioPlayer.processingState == ProcessingState.completed && widget.audioPlayerController.audioPlayer.position != Duration.zero
              ? IconButton(
            key: const ValueKey<String>('replay_button'),
            icon: Icon(Icons.replay_rounded, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              widget.audioPlayerController.audioPlayer.seek(Duration.zero);
              widget.audioPlayerController.play();
            },
            iconSize: 45.0,
          )
              : AnimatedIcon(
            key: const ValueKey<String>('play_pause_icon'),
            icon: AnimatedIcons.play_pause,
            progress: _controller,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 45.0,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
