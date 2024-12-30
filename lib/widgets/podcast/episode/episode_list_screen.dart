import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/utils.dart';
import '../../../controller/audio_player_controller.dart';
import '../../../controller/podcast_controller.dart';
import '../../../controller/podcast_episode_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../../../routes/routes.dart';
import '../../common/loading_widget.dart';
import '../../providers/radio_podcast_provider.dart';
import 'episode_list_details_screen.dart';

class EpisodeListScreen extends StatefulWidget {
  const EpisodeListScreen({super.key});

  @override
  State<EpisodeListScreen> createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeListScreen> {
  final podcastEpisodeController = Get.put(PodcastEpisodeController());
  final PodcastController podcastController = Get.find<PodcastController>();
  final AudioPlayerController audioPlayerController= Get.find<AudioPlayerController>();

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
              childAspectRatio: Utils.calculateHeight(context, 0.00077),
              mainAxisExtent: Utils.calculateHeight(context, 0.38),
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
          //Set the selected episode using the controller
          podcastEpisodeController.setSelectedEpisode(podcastEpisode);
          //Navigate to the "PodcastPage"
          Get.toNamed(Routes.getPodcastRoute());
        },
        child: EpisodeListDetailsWidget(episode: podcastEpisode,
          audioPlayerController: audioPlayerController,
        ),
    );
  }

}