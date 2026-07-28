import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/nav_bar/responsive_scaffold.dart';
import 'package:avvento_media/controller/nav_bar_controller.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
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
    return GetBuilder<NavBarController>(builder: (_) {
      return UpgradeAlert(
        child: ResponsiveScaffold(
          currentIndex: controller.tabIndex,
          onTabSelected: controller.changeTabIndex,
          bodyWrapper: (context, child) {
            return DoubleBackToCloseApp(
              snackBar: SnackBar(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                content: const Text(AppConstants.exitApp),
              ),
              child: child,
            );
          },
          pages: const [
            HomePage(),
            ListenPage(),
            SearchPage(),
            ProfilePage(),
          ],
        ),
      );
    });
  }
}
