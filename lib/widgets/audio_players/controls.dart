import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

class Controls extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const Controls({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _ControlsState createState() => _ControlsState();
}

class _ControlsState extends State<Controls> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Adjust the animation duration as needed
    );

    widget.audioPlayer.playerStateStream.listen((playerState) {
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
          widget.audioPlayer.pause();
        } else {
          widget.audioPlayer.play();
        }
      },
      child: AnimatedIcon(
        icon: AnimatedIcons.play_pause, // Change this to the desired AnimatedIcon
        progress: _controller,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 55.0, // Adjust the size as needed
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
