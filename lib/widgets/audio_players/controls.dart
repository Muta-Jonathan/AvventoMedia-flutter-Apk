import 'package:flutter/material.dart';

import '../../controller/audio_player_controller.dart';

class Controls extends StatefulWidget {
  final AudioPlayerController audioPlayerController;

  const Controls({super.key, required this.audioPlayerController});

  @override
  ControlsState createState() => ControlsState();
}

class ControlsState extends State<Controls>
    with SingleTickerProviderStateMixin {
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
        _controller.forward();
      } else {
        _controller.reverse();
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
          child: AnimatedIcon(
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
