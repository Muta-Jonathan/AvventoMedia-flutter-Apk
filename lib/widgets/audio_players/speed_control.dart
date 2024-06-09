import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../componets/utils.dart';

class SpeedControl extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const SpeedControl({super.key, required this.audioPlayer});

  @override
  SpeedControlState createState() => SpeedControlState();
}

class SpeedControlState extends State<SpeedControl> {
  List<double> speeds = [1.0, 1.25, 1.5, 1.75, 2.0];
  int currentSpeedIndex = 0;

  void _changeSpeed() {
    setState(() {
      currentSpeedIndex = (currentSpeedIndex + 1) % speeds.length;
      widget.audioPlayer.setSpeed(speeds[currentSpeedIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeSpeed,
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.all(5.0),
        width: Utils.calculateWidth(context, 0.16),
        height: Utils.calculateHeight(context, 0.045),
        decoration: BoxDecoration(
          border: Border.all(
            color:  Theme.of(context).colorScheme.onPrimary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          '${speeds[currentSpeedIndex]}x',
          style: TextStyle(
            color:  Theme.of(context).colorScheme.onPrimary,
            fontSize: Utils.calculateHeight(context, 0.023),
          ),
        ),
      ),
    );
  }
}
