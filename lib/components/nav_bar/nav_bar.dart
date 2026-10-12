import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/nav_bar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';

import '../../main.dart' show miniPlayerMinHeight;
import '../../pages/home_page.dart';
import '../../pages/listen_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/search_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final controller = Get.put(NavBarController());

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioPlayerController>();

    return GetBuilder<NavBarController>(builder: (_) {
      return UpgradeAlert(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: _BackToExit(
            controller: controller,
            child: IndexedStack(
              index: controller.tabIndex,
              children: const [
                HomePage(),
                ListenPage(),
                SearchPage(),
                ProfilePage(),
              ],
            ),
          ),

          // Reserves space for the root-level mini bar above the BottomNav (so
          // body content and snackbars clear it). The reserve is fixed so the
          // tab pages aren't re-laid out on every drag frame. The BottomNav
          // fades out by 33 % expansion.
          bottomNavigationBar: Obx(() {
            final pct = audioController.panelPercentage.value;
            final showPlayer = audioController.isPlayerActive.value &&
                audioController.isMiniPlayerVisible.value;

            final reserved = showPlayer ? miniPlayerMinHeight : 0.0;
            final opacity = showPlayer ? (1.0 - pct * 3).clamp(0.0, 1.0) : 1.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: reserved),
                if (opacity > 0.0)
                  Opacity(
                    opacity: opacity,
                    child: BottomNavigationBar(
                      currentIndex: controller.tabIndex,
                      onTap: controller.changeTabIndex,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedItemColor:
                          Theme.of(context).colorScheme.onPrimary,
                      unselectedItemColor: Theme.of(context).iconTheme.color,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      selectedFontSize: 10,
                      unselectedFontSize: 10,
                      elevation: 0,
                      items: const [
                        BottomNavigationBarItem(
                            label: "Videos",
                            icon: Icon(CupertinoIcons.play_circle)),
                        BottomNavigationBarItem(
                            label: "Audio",
                            icon: Icon(CupertinoIcons.headphones)),
                        BottomNavigationBarItem(
                            label: "Search", icon: Icon(CupertinoIcons.search)),
                        BottomNavigationBarItem(
                            label: "More",
                            icon: Icon(CupertinoIcons.person_crop_circle)),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ),
      );
    });
  }
}

/// Back on the home screen: closes the expanded player first, goes to the
/// Home tab from the others, then needs a second press within 2 s to exit.
class _BackToExit extends StatefulWidget {
  const _BackToExit({required this.controller, required this.child});

  final NavBarController controller;
  final Widget child;

  @override
  State<_BackToExit> createState() => _BackToExitState();
}

class _BackToExitState extends State<_BackToExit> {
  static const _window = Duration(seconds: 2);
  DateTime? _lastBack;

  void _onBack() {
    // Expanded player (or another LocalHistoryEntry): let it handle Back.
    if (ModalRoute.of(context)?.willHandlePopInternally ?? false) {
      Navigator.of(context).pop();
      return;
    }
    if (widget.controller.tabIndex != 0) {
      widget.controller.changeTabIndex(0);
      return;
    }
    final now = DateTime.now();
    if (_lastBack != null && now.difference(_lastBack!) < _window) {
      SystemNavigator.pop();
      return;
    }
    _lastBack = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text(AppConstants.exitApp),
        duration: _window,
      ));
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onBack();
        },
        child: widget.child,
      );
}
