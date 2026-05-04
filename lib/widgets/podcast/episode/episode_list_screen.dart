import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controller/audio_player_controller.dart';
import '../../../controller/podcast_controller.dart';
import '../../../controller/podcast_episode_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../../../routes/routes.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio/just_audio.dart';
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: podcastProvider.podcastEpisodes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                return buildRadioPodcastDetailsScreen(podcastProvider.podcastEpisodes[index]);
              },
            ),
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

          final provider = Provider.of<RadioPodcastProvider>(context, listen: false);
          final episodes = provider.podcastEpisodes;
          final initialIndex = episodes.indexOf(podcastEpisode);
          
          List<AudioSource> audioSources = episodes.map((ep) => AudioSource.uri(
            Uri.parse(ep.downloadLink),
            tag: MediaItem(
              id: ep.id,
              title: ep.title,
              artist: ep.playlistMediaArtist,
              artUri: Uri.parse(ep.art),
            ),
          )).toList();
          
          audioPlayerController.setAudioPlaylist(audioSources, initialIndex >= 0 ? initialIndex : 0);

          //Navigate to the "PodcastPage"
          Get.toNamed(Routes.getPodcastRoute());
        },
        child: EpisodeListDetailsWidget(episode: podcastEpisode,
          audioPlayerController: audioPlayerController,
        ),
    );
  }

}