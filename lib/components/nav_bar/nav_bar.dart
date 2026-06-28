import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/nav_bar_controller.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';

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
    return GetBuilder<NavBarController>(builder: (_){
      return UpgradeAlert(
        // Check for updates from Store according to the build number
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: DoubleBackToCloseApp(
            snackBar: SnackBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              content: const Text(AppConstants.exitApp),
            ),
              child:IndexedStack(
                index: controller.tabIndex,
                children: const [
                  HomePage(),
                  ListenPage(),
                  SearchPage(),
                  ProfilePage(),
                ],
              ),
          ),
          bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.tabIndex,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.onPrimary,
          unselectedItemColor: Theme.of(context).iconTheme.color,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          //Bottom Navigation Bar with [Home,Listen,Profile]
          items: const [
            BottomNavigationBarItem(label: "Videos", icon: Icon(CupertinoIcons.play_circle)),
            BottomNavigationBarItem(label: "Audio", icon: Icon(CupertinoIcons.headphones)),
            BottomNavigationBarItem(label: "Search", icon: Icon(CupertinoIcons.search)),
            BottomNavigationBarItem(label: "More", icon: Icon(CupertinoIcons.person_crop_circle)),
          ],
          ),
        ),
      );
    });
  }
}
