import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/providers/radio_podcast_provider.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/images/resizable_image_widget_2.dart';
import '../widgets/podcast/podcast_list_screen.dart';

class PodcastListPage extends StatefulWidget {
  const PodcastListPage({super.key});

  @override
  State<PodcastListPage> createState() => _PodcastListPageState();
}

class _PodcastListPageState extends State<PodcastListPage> {
  @override
  Widget build(BuildContext context) {
    Future<void> refreshData() async {
      // Fetch fresh data for PodcastScreen
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
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                expandedHeight: Utils.calculateHeight(context, 0.4),
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.blurBackground
                  ],
                  title: TextOverlay(
                    label: AppConstants.podcasts,
                    color: Theme.of(context).colorScheme.onPrimary,
                    maxLines: 1,
                    fontSize: 18,
                  ),
                  centerTitle: true,
                  expandedTitleScale: 1,
                  collapseMode: CollapseMode.pin,
                  background: const SizedBox(
                    height: AppConstants.height250,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 105, right: 20, left: 20, bottom: 60),
                      child: ResizableImageContainerWithOverlay(
                        imageUrl: AppConstants. podcastThumbImage,
                        borderRadius: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                  child: PodcastListScreen()
              ),

            ],
        ),
      ),
    );
  }
}

