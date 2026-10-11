import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/audio_player_controller.dart';
import '../main.dart' show miniPlayerMinHeight;
import '../routes/routes.dart';

/// The app's one snackbar: a short message with an optional action (e.g.
/// Undo), styled by the theme's [SnackBarThemeData].
class AppSnackbar {
  static const _duration = Duration(seconds: 4);

  /// [navigator] is the Navigator the caller lives on. Pass it from sheets
  /// that may already be closed.
  static void show(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    NavigatorState? navigator,
  }) {
    final player = Get.isRegistered<AudioPlayerController>()
        ? Get.find<AudioPlayerController>()
        : null;

    // Inside the full player: the root overlay sits under it, so use the
    // player's own ScaffoldMessenger.
    if (navigator != null &&
        navigator.mounted &&
        identical(navigator, player?.fullPlayerNavigator)) {
      ScaffoldMessenger.of(navigator.context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(message),
          duration: _duration,
          action: actionLabel == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
        ));
      return;
    }

    // Everywhere else: GetX's root overlay, so it shows above open sheets.
    final theme = Get.theme.snackBarTheme;
    Get.closeCurrentSnackbar();
    Get.showSnackbar(GetSnackBar(
      messageText: Text(message, style: theme.contentTextStyle),
      backgroundColor: theme.backgroundColor ?? const Color(0xFF313033),
      borderRadius: 8,
      margin: EdgeInsets.fromLTRB(12, 0, 12, 8 + _bottomClearance(player)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: _duration,
      animationDuration: const Duration(milliseconds: 250),
      dismissDirection: DismissDirection.horizontal,
      mainButton: actionLabel == null
          ? null
          : TextButton(
              onPressed: () {
                Get.closeCurrentSnackbar();
                onAction?.call();
              },
              child: Text(actionLabel,
                  style: TextStyle(
                      color: theme.actionTextColor,
                      fontWeight: FontWeight.bold)),
            ),
    ));
  }

  /// On the home tabs the BottomNav (and the collapsed mini bar above it) sit
  /// over the overlay's bottom edge. Other routes are already padded.
  static double _bottomClearance(AudioPlayerController? player) {
    final route = player?.currentRoute.value ?? Get.currentRoute;
    if (route != Routes.home && route != '/') return 0;
    final miniBar = (player?.isPlayerActive.value ?? false) &&
            (player?.isMiniPlayerVisible.value ?? false)
        ? miniPlayerMinHeight
        : 0.0;
    return kBottomNavigationBarHeight + miniBar;
  }
}
