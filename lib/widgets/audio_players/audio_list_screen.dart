import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/widgets/text/label_place_holder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/podcast_controller.dart';
import '../../models/radiomodel/radio_podcast_model.dart';
import '../../routes/routes.dart';
import '../common/loading_widget.dart';
import '../podcast/podcast_list_details_screen.dart';
import '../providers/radio_podcast_provider.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListState();
}

class _AudioListState extends State<AudioListScreen> {
  final podcastController = Get.put(PodcastController());
  @override
  void initState() {
    super.initState();
    // Fetch episodes using the provider and listen to changes
    Provider.of<RadioPodcastProvider>(context, listen: false).fetchAllPodcasts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      width:  Utils.calculateWidth(context, 0.95),
      height: Utils.calculateHeight(context, 0.42),
      child: Column(
        children: [
          const SizedBox(height: 10),
          LabelPlaceHolder(title: AppConstants.podcasts, moreIcon: true, onMoreTap: () => Get.toNamed(Routes.getPodcastListRoute())),
          Padding(
            padding: const EdgeInsets.only(left: AppConstants.leftMain, right: AppConstants.rightMain),
            child: Divider(color: Theme.of(context).colorScheme.tertiaryContainer,),
          ),
          Expanded(child: buildListView(context)),
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return Consumer<RadioPodcastProvider>(
      builder: (context, podcastProvider, child) {
        if (podcastProvider.podcasts.isEmpty) {
          return const LoadingWidget();
        } else {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: podcastProvider.podcasts.length,
            itemBuilder: (BuildContext context, int index) {
              return buildRadioPodcastDetailsScreen(podcastProvider.podcasts[index]);
            },
          );
        }
      },
    );
  }

  Widget buildRadioPodcastDetailsScreen(RadioPodcast radioPodcast) {
    return GestureDetector(
      onTap: () {
        // Set the selected episode using the controller
        podcastController.setSelectedEpisode(radioPodcast);
        // Navigate to the "PodcastPage"
        Get.toNamed(Routes.getPodcastEpisodeListRoute());
      },
      child: PodcastListDetailsWidget(radioPodcast: radioPodcast,),
    );
  }

}