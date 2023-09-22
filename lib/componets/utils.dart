import 'package:flutter/cupertino.dart';

class Utils {
  static double calculateHeight(BuildContext context, width) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = width * screenWidth;
    return widgetWidth * 9.0 / 16.0;
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

}