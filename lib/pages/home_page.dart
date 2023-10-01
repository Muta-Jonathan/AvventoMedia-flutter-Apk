import 'package:avvento_radio/routes/routes.dart';
import 'package:avvento_radio/widgets/explore/home_explore_screen.dart';
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
  Future<void> _refreshData() async {
    // Add your data refresh logic here
    await Future.delayed(Duration(seconds: 2)); // Simulate data loading
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              floating: true,
              title: Text(AppConstants.appName),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.headphones),
                  onPressed: () {
                    Get.toNamed(Routes.getListenRoute());
                  },
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  Divider(),
                  HomeExploreScreen(),
                  HomeExploreScreen(),
                  HomeExploreScreen(),
                  HomeExploreScreen(),
                  HomeExploreScreen(),
                  HomeExploreScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
