import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/nav_bar_controller.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          body: DoubleBackToCloseApp(
            snackBar: SnackBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              content: const Text(AppConstants.exitApp),
            ),
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
          // body content and snackbars clear it). The BottomNav fades out by
          // 33 % expansion.
          bottomNavigationBar: Obx(() {
            final pct = audioController.panelPercentage.value;
            final showPlayer = audioController.isPlayerActive.value &&
                audioController.isMiniPlayerVisible.value;

            final reserved = showPlayer
                ? miniPlayerMinHeight * (1.0 - pct).clamp(0.0, 1.0)
                : 0.0;
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
