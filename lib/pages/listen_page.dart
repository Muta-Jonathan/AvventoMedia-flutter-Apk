import 'package:avvento_media/widgets/podcast/audio_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/app_constants.dart';
import '../routes/routes.dart';
import '../widgets/providers/programs_provider.dart';
import '../widgets/providers/radio_podcast_provider.dart';
import '../widgets/text/label_place_holder.dart';
import '../widgets/explore/carousel_slider.dart';

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
      await Provider.of<RadioPodcastProvider>(context, listen: false).fetchAllPodcasts();

      await Future.delayed(const Duration(seconds: 2)); // Simulate data loading
    }
    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.amber,
        onRefresh: refreshData,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor:   Theme.of(context).colorScheme.surface,
              iconTheme:IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
              floating: true,
              title: Column(
                children: [
                  const SizedBox(height: 15),
                  Text(AppConstants.radioName,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.antenna_radiowaves_left_right),
                  onPressed: () {
                    Get.toNamed(Routes.getOnlineRadioRoute());
                  },
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 5),
                  LabelPlaceHolder(title: AppConstants.missNot),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 210, // 👈 give CarouselPage a fixed height
                    child: CarouselSlider(),
                  ),
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
