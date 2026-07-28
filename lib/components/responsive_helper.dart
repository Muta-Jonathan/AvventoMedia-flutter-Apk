import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, tv, desktop }

class ResponsiveHelper {
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMax;
  }

  static bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width < tabletMax && !isTvPlatform();
  }

  static bool isTv(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= tabletMax || isTvPlatform();
  }

  static bool isDesktop(BuildContext context) {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  static bool isTvPlatform() {
    if (kIsWeb) return false;
    // Check if Android TV / Apple TV or TV mode (can be refined via TargetPlatform)
    return defaultTargetPlatform == TargetPlatform.android &&
        (Platform.environment.containsKey('TV') ||
            Platform.operatingSystemVersion.toLowerCase().contains('tv'));
  }

  static DeviceType getDeviceType(BuildContext context) {
    if (isTv(context)) return DeviceType.tv;
    if (isTablet(context)) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static int getGridCrossAxisCount(BuildContext context, {int mobile = 2, int tablet = 3, int tv = 5}) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1400) return tv + 1;
    if (width >= tabletMax) return tv;
    if (width >= mobileMax) return tablet;
    return mobile;
  }

  static EdgeInsets getTvSafePadding(BuildContext context) {
    if (!isTv(context)) return EdgeInsets.zero;
    double width = MediaQuery.of(context).size.width;
    double paddingHorizontal = width * 0.04;
    return EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 16);
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    DeviceType deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}
