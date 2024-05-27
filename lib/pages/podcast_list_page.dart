import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/images/resizable_image_widget_2.dart';
import '../widgets/music/music_list_screen.dart';

class PodcastListPage extends StatefulWidget {
  const PodcastListPage({super.key});

  @override
  State<PodcastListPage> createState() => _PodcastListPageState();
}

class _PodcastListPageState extends State<PodcastListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            expandedHeight: 310,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: TextOverlay(
                label: 'PODCASTS',
                color: Theme.of(context).colorScheme.onPrimary,
                maxLines: 1,
                fontSize: 18,
              ),
              centerTitle: true,
              expandedTitleScale: 1,
              collapseMode: CollapseMode.pin,
              background: const SizedBox(
                height: 250,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 105, right: 20, left: 20, bottom: 60),
                  child: ResizableImageContainerWithOverlay(
                    imageUrl:
                    'https://avventomedia.org/home/old/wp-content/uploads/2022/10/3ABN_UG_app.png',
                    borderRadius: 10,
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: MusicListScreen()
          ),

        ],
      ),
    );
  }
}

