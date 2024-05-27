import 'dart:developer';

import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../componets/utils.dart';
import '../../controller/episode_controller.dart';
import '../../controller/podcast_controller.dart';
import '../../controller/podcast_episode_controller.dart';
import '../../models/radiomodel/podcast_episode_model.dart';
import '../../models/spreakermodels/spreaker_episodes.dart';
import '../../routes/routes.dart';
import '../common/loading_widget.dart';
import '../podcast/podcast_list_details_screen.dart';
import 'episode_list_details_screen.dart';
import '../providers/radio_podcast_provider.dart';
import '../providers/spreaker_data_provider.dart';

class EpisodeListScreen extends StatefulWidget {
  const EpisodeListScreen({super.key});

  @override
  State<EpisodeListScreen> createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeListScreen> {
  final PodcastController podcastController = Get.find();

  @override
  void initState() {
    super.initState();
    // Fetch episodes using the provider and listen to changes
    Provider.of<RadioPodcastProvider>(context, listen: false).fetchAllEpisodes(podcastController.selectedEpisode.value!.episodesLink);
  }

  @override
  Widget build(BuildContext context) {
    return buildGridView(context);
  }

  Widget buildGridView(BuildContext context) {
    return Consumer<RadioPodcastProvider>(
      builder: (context, podcastProvider, child) {
        if (podcastProvider.podcastEpisodes.isEmpty) {
          return const LoadingWidget();
        } else {
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: Utils.calculateHeight(context, 0.0008),
            ),
            itemCount: podcastProvider.podcastEpisodes.length,
            semanticChildCount: 2,
            itemBuilder: (BuildContext context, int index) {
              return  buildRadioPodcastDetailsScreen(podcastProvider.podcastEpisodes[index]);
            },
          );
        }
      },
    );
  }

  Widget buildRadioPodcastDetailsScreen(PodcastEpisode podcastEpisode) {
    return GestureDetector(
        onTap: () {
          // Set the selected episode using the controller
          //episodeController.setSelectedEpisode(r);
          // Navigate to the "PodcastPage"
          //Get.toNamed(Routes.getPodcastRoute());
        },
        child: EpisodeListDetailsWidget(episode: podcastEpisode,),
    );
  }

}