import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class TextColoriser extends StatelessWidget {
  final String text;

  const TextColoriser({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.blue,
      Colors.purple,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
    );

    return AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            text,
            textStyle: colorizeTextStyle,
            colors: colorizeColors,
          )
        ],
        isRepeatingAnimation: true,
        displayFullTextOnTap: true,
        repeatForever: true,
        stopPauseOnTap: true,
        pause: const Duration(seconds: 2),
    );
  }
}
