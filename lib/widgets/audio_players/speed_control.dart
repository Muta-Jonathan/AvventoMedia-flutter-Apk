import 'package:flutter/material.dart';

import '../../controller/audio_player_controller.dart';

class SpeedControl extends StatelessWidget {
  final AudioPlayerController audioPlayerController;

  const SpeedControl({super.key, required this.audioPlayerController});

  void _showSpeedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StreamBuilder<double>(
          stream: audioPlayerController.audioPlayer.speedStream,
          builder: (context, snapshot) {
            final currentSpeed = snapshot.data ?? 1.0;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Playback Speed",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...audioPlayerController.speeds.map((speed) {
                    final isSelected = currentSpeed == speed;
                    return ListTile(
                      title: Text(
                        "${speed}x",
                        style: TextStyle(
                          color: isSelected ? Colors.amber : Theme.of(context).colorScheme.onPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.amber) : null,
                      onTap: () {
                        audioPlayerController.currentSpeedIndex = audioPlayerController.speeds.indexOf(speed);
                        audioPlayerController.audioPlayer.setSpeed(speed);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.speed_rounded),
      color: Theme.of(context).colorScheme.onSecondary,
      iconSize: 28,
      onPressed: () => _showSpeedBottomSheet(context),
    );
  }
}
