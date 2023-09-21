import 'package:avvento_radio/componets/routes.dart';
import 'package:avvento_radio/widgets/explore_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componets/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  //on tap to go to different screens per index
  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          //Notification bell Icon to go to Explore screen
          IconButton( icon: const Icon(CupertinoIcons.bell), onPressed:(){ Get.toNamed(Routes.getListenRoute());},)
        ],
      ),
      body: const Column(
        children: [
          Divider(),
          ExploreScreen()
        ],
      ),
    );
  }
}
