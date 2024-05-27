import 'dart:developer';

import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../componets/utils.dart';
import '../../controller/episode_controller.dart';
import '../../controller/podcast_controller.dart';
import '../../models/spreakermodels/spreaker_episodes.dart';
import '../../routes/routes.dart';
import '../common/loading_widget.dart';
import 'podcast_list_details_screen.dart';
import '../providers/radio_podcast_provider.dart';
import '../providers/spreaker_data_provider.dart';

class PodcastListScreen extends StatefulWidget {
  const PodcastListScreen({super.key});

  @override
  State<PodcastListScreen> createState() => _PodcastListState();
}

class _PodcastListState extends State<PodcastListScreen> {
  final podcastController = Get.put(PodcastController());
  @override
  void initState() {
    super.initState();
    // Fetch episodes using the provider and listen to changes
    Provider.of<RadioPodcastProvider>(context, listen: false).fetchAllPodcasts();
  }

  @override
  Widget build(BuildContext context) {
    return buildGridView(context);
  }

  Widget buildGridView(BuildContext context) {
    return Consumer<RadioPodcastProvider>(
      builder: (context, podcastProvider, child) {
        if (podcastProvider.podcasts.isEmpty) {
          return const LoadingWidget();
        } else {
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: Utils.calculateHeight(context, 0.00085),
            ),
            itemCount: podcastProvider.podcasts.length,
            semanticChildCount: 2,
            itemBuilder: (BuildContext context, int index) {
              return  buildRadioPodcastDetailsScreen(podcastProvider.podcasts[index]);
            },
          );
        }
      },
    );
  }

  Widget buildRadioPodcastDetailsScreen(RadioPodcast radioPodcast) {
    return GestureDetector(
        onTap: () {
          // Set the selected podcast using the controller
          podcastController.setSelectedEpisode(radioPodcast);
          // Navigate to the "PodcastEpisodePage"
          Get.toNamed(Routes.getPodcastEpisodeListRoute());
        },
        child: PodcastListDetailsWidget(radioPodcast: radioPodcast,),
    );
  }

}