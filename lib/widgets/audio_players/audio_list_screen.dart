import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/widgets/text/label_place_holder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/episode_controller.dart';
import '../../models/spreakermodels/spreaker_episodes.dart';
import '../../routes/routes.dart';
import '../providers/spreaker_data_provider.dart';
import 'audio_list_details_screen.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListState();
}

class _AudioListState extends State<AudioListScreen> {
  final episodeController = Get.put(EpisodeController());
  @override
  void initState() {
    super.initState();
    // Fetch episodes using the provider and listen to changes
    Provider.of<SpreakerEpisodeProvider>(context, listen: false).fetchEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      width:  Utils.calculateWidth(context, 0.95),
      height: Utils.calculateHeight(context, 0.9),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const LabelPlaceHolder(title: AppConstants.spreaker),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Divider(),
          ),
          Expanded(child: buildListView(context)),
          const Divider()
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return Consumer<SpreakerEpisodeProvider>(
      builder: (context, episodeProvider, child) {
        if (episodeProvider.episodes.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        } else {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: episodeProvider.episodes.length,
            itemBuilder: (BuildContext context, int index) {
              return buildSpreakerDetailsScreen(episodeProvider.episodes[index]);
            },
          );
        }
      },
    );
  }

  Widget buildSpreakerDetailsScreen(SpreakerEpisode spreakerEpisode) {
    return GestureDetector(
      onTap: () {
        // Set the selected episode using the controller
        episodeController.setSelectedEpisode(spreakerEpisode);
        // Navigate to the "PodcastPage"
        Get.toNamed(Routes.getPodcastRoute());
      },
      child: AudioListDetailsWidget(spreakerEpisode: spreakerEpisode),
    );
  }

}