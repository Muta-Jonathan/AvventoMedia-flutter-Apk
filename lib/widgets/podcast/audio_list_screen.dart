import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/widgets/text/label_place_holder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/podcast_controller.dart';
import '../../models/radiomodel/radio_podcast_model.dart';
import '../../routes/routes.dart';
import '../common/loading_widget.dart';
import 'podcast_list_details_screen.dart';
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
    return Column(
      children: [
        const SizedBox(height: 10),
        LabelPlaceHolder(
          title: AppConstants.podcasts,
          moreIcon: true,
          onMoreTap: () => Get.toNamed(Routes.getPodcastListRoute()),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.leftMain,
            right: AppConstants.rightMain,
          ),
          child: Divider(
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        _buildGridView(context),
      ],
    );
  }

  Widget _buildGridView(BuildContext context) {
    return Consumer<RadioPodcastProvider>(
      builder: (context, podcastProvider, child) {
        if (podcastProvider.podcasts.isEmpty) {
          return const SizedBox(
            height: 200,
            child: LoadingWidget(),
          );
        } else {
          // Take only the 4 most recent podcasts for the 2x2 grid
          final recentPodcasts = podcastProvider.podcasts.take(4).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.leftMain,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: recentPodcasts.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildPodcastCard(recentPodcasts[index]);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildPodcastCard(RadioPodcast radioPodcast) {
    return GestureDetector(
      onTap: () {
        // Set the selected episode using the controller
        podcastController.setSelectedEpisode(radioPodcast);
        // Navigate to the "PodcastPage"
        Get.toNamed(Routes.getPodcastEpisodeListRoute());
      },
      child: PodcastListDetailsWidget(radioPodcast: radioPodcast),
    );
  }

}