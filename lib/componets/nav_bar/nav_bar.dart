import 'package:avvento_radio/controller/nav_bar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/home_page.dart';
import '../../pages/listen_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/watch_page.dart';

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
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: IndexedStack(
          index: controller.tabIndex,
          children: const [
            HomePage(),
            WatchPage(),
            ListenPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.tabIndex,
        onTap: controller.changeTabIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.background,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        elevation: 0,
        //Bottom Navigation Bar with [Home,Listen,Schedule,Profile]
        items: const [
          BottomNavigationBarItem(label: "Home",icon: Icon(CupertinoIcons.house_alt)),
          BottomNavigationBarItem(label: "Watch",icon: Icon(CupertinoIcons.tv)),
          BottomNavigationBarItem(label: "Listen",icon: Icon(CupertinoIcons.headphones)),
          BottomNavigationBarItem(label: "Profile",icon: Icon(CupertinoIcons.person)),
        ],
        ),
      );
    });
  }
}
