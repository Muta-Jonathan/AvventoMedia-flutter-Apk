import 'package:avvento_media/widgets/podcast/audio_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/app_constants.dart';
import '../components/responsive_helper.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.amber,
        onRefresh: refreshData,
        child: CustomScrollView(
          slivers: <Widget>[
            if (ResponsiveHelper.isTv(context))
              const SliverToBoxAdapter(
                child: SizedBox(height: 70),
              ),
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
              floating: true,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade600, Colors.amber.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.headphones,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppConstants.radioName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(CupertinoIcons.antenna_radiowaves_left_right, size: 20),
                    onPressed: () {
                      Get.toNamed(Routes.getOnlineRadioRoute());
                    },
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Live Radio banner
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.leftMain,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.getOnlineRadioRoute());
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.secondary,
                              Colors.amber.shade900.withValues(alpha: 0.4),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                CupertinoIcons.antenna_radiowaves_left_right,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppConstants.liveRadio,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Tune in to ${AppConstants.radioName}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_right,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const LabelPlaceHolder(title: AppConstants.missNot),
                  const SizedBox(height: 12),
                  const SizedBox(
                    height: 210, // 👈 give CarouselPage a fixed height
                    child: CarouselSlider(),
                  ),
                  const SizedBox(height: 8),
                  const AudioListScreen(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
