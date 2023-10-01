import 'package:avvento_radio/widgets/audio_players/audio_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:marquee/marquee.dart';

import '../componets/app_constants.dart';
import '../routes/routes.dart';
import '../widgets/explore/home_explore_screen.dart';

class ListenPage extends StatefulWidget {
  const ListenPage({Key? key}) : super(key: key);

  @override
  ListenPageState createState() => ListenPageState();
}

class ListenPageState extends State<ListenPage> {
  @override
  Widget build(BuildContext context) {
    Future<void> _refreshData() async {
      // Add your data refresh logic here
      await Future.delayed(Duration(seconds: 2)); // Simulate data loading
    }
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
              title: const Text(AppConstants.radioName),
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
                  AudioListScreen()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
