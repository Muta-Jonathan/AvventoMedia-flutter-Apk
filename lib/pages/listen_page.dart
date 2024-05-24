import 'package:avvento_media/widgets/audio_players/audio_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../componets/app_constants.dart';
import '../routes/routes.dart';
import '../widgets/explore/home_explore_screen.dart';
import '../widgets/providers/programs_provider.dart';
import '../widgets/providers/spreaker_data_provider.dart';

class ListenPage extends StatefulWidget {
  const ListenPage({super.key});

  @override
  ListenPageState createState() => ListenPageState();
}

class ListenPageState extends State<ListenPage> {
  @override
  Widget build(BuildContext context) {
    Future<void> refreshData() async {
      // Fetch fresh data for HomeExploreScreen
      await Provider.of<ProgramsProvider>(context, listen: false).fetchData();
      if (!context.mounted) return;
      // Fetch fresh data for AudioListScreen
      await Provider.of<SpreakerEpisodeProvider>(context, listen: false).fetchEpisodesWithLimits();

      await Future.delayed(const Duration(seconds: 2)); // Simulate data loading
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.orange,
        onRefresh: refreshData,
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
                    Get.toNamed(Routes.getOnlineRadioRoute());
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
