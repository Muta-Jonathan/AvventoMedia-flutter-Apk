import 'package:flutter/cupertino.dart';

class Utils {
  static double calculateAspectHeight(BuildContext context, width) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = width * screenWidth;
    return widgetWidth * 9.0 / 16.0;
  }

  static double calculateHeight(BuildContext context, height) {
    double screenHeight = MediaQuery.of(context).size.height;
    double widgetHeight = height * screenHeight;
    return  widgetHeight;
  }

  static double calculateWidth(BuildContext context, width) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = width * screenWidth;
    return  widgetWidth;
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

}