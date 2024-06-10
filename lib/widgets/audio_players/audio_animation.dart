import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AudioIndicator extends StatelessWidget {
  final bool isPlaying;

  const AudioIndicator({super.key, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/audio_indicator.json',
      width: 80,
      height: 80,
      animate: isPlaying,
    );
  }
}
