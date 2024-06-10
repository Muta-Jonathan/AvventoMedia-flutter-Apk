import 'package:flutter/material.dart';

import '../../componets/utils.dart';
import '../../controller/audio_player_controller.dart';

class SpeedControl extends StatefulWidget {
  final AudioPlayerController audioPlayerController;

  const SpeedControl({super.key, required this.audioPlayerController});

  @override
  SpeedControlState createState() => SpeedControlState();
}

class SpeedControlState extends State<SpeedControl> {
  void _changeSpeed() {
    setState(() {
      widget.audioPlayerController.currentSpeedIndex = (widget.audioPlayerController.currentSpeedIndex + 1) % widget.audioPlayerController.speeds.length;
      widget. audioPlayerController.audioPlayer.setSpeed( widget.audioPlayerController.speeds[widget.audioPlayerController.currentSpeedIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeSpeed,
      child: Container(
        margin: const EdgeInsets.only(left: 10,bottom: 10),
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
          '${widget.audioPlayerController.speeds[widget.audioPlayerController.currentSpeedIndex]}x',
          style: TextStyle(
            color:  Theme.of(context).colorScheme.onPrimary,
            fontSize: Utils.calculateWidth(context, 0.05),
          ),
        ),
      ),
    );
  }
}
