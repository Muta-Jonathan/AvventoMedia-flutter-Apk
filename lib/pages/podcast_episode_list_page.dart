import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/providers/radio_podcast_provider.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controller/podcast_controller.dart';
import '../widgets/images/resizable_image_widget_2.dart';
import '../widgets/podcast/episode/episode_list_screen.dart';
import '../widgets/text/show_more_desc.dart';

class PodcastEpisodeListPage extends StatefulWidget {
  const PodcastEpisodeListPage({super.key});

  @override
  State<PodcastEpisodeListPage> createState() => _PodcastEpisodeListPageState();
}

class _PodcastEpisodeListPageState extends State<PodcastEpisodeListPage> {
  final PodcastController podcastController = Get.find();
  @override
  Widget build(BuildContext context) {
    final int itemCount = podcastController.selectedEpisode.value!.episodes;
    String episodeCountLabel = itemCount == 1 ? '$itemCount episode' : '$itemCount episodes';

    Future<void> refreshData() async {
      // Fetch fresh data for a specific podcast
      await Provider.of<RadioPodcastProvider>(context, listen: false).fetchAllEpisodes(podcastController.selectedEpisode.value!.episodesLink);

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
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                expandedHeight: Utils.calculateHeight(context, 0.4),
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.blurBackground
                  ],
                  title: TextOverlay(
                    label: podcastController.selectedEpisode.value!.title,
                    color: Theme.of(context).colorScheme.onPrimary,
                    maxLines: 1,
                    fontSize: 18,
                  ),
                  centerTitle: true,
                  expandedTitleScale: 1,
                  collapseMode: CollapseMode.pin,
                  background: SizedBox(
                    height: AppConstants.height250,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 105, right: 20, left: 20, bottom: 60),
                      child: ResizableImageContainerWithOverlay(
                        imageUrl: podcastController.selectedEpisode.value!.art,
                        borderRadius: 10,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      podcastController.selectedEpisode.value!.description.trim() != '' ?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextOverlay(label: AppConstants.description, color: Theme.of(context).colorScheme.onPrimary,fontSize: AppConstants.fontSize18,fontWeight: FontWeight.bold,),
                          const SizedBox(height: 5),
                          ShowMoreDescription(description: podcastController.selectedEpisode.value!.description,modalTitle: AppConstants.description,),
                        ],
                      )
                      : const SizedBox.shrink(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextOverlay(label: episodeCountLabel, color: Theme.of(context).colorScheme.onPrimary,fontSize: 15),
                        ],
                      ),
                      Divider(color: Theme.of(context).colorScheme.tertiaryContainer,),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                  child: EpisodeListScreen()
              ),

            ],
          ),
      ),
    );
  }
}

