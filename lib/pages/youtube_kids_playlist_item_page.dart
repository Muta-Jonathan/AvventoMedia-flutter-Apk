import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../apis/firestore_service_api.dart';
import '../controller/youtube_playlist_item_controller.dart';
import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../routes/routes.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/share_button.dart';
import '../widgets/images/resizable_image_widget_2.dart';
import '../widgets/text/show_more_desc.dart';
import '../widgets/youtube/items/youtube_playlist_item_details_widget.dart';

class YoutubeKidsPlaylistItemPage extends StatefulWidget {
  const YoutubeKidsPlaylistItemPage({super.key});

  @override
  State<YoutubeKidsPlaylistItemPage> createState() => _YoutubePlaylistItemPageState();
}

class _YoutubePlaylistItemPageState extends State<YoutubeKidsPlaylistItemPage> {
  final YoutubePlaylistController youtubePlaylistController = Get.find();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlaylist = youtubePlaylistController.selectedPlaylist.value!;
    final int itemCount = selectedPlaylist.itemCount;
    String videoCountLabel = itemCount == 1 ? '$itemCount video' : '$itemCount videos';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            expandedHeight: Utils.calculateHeight(context, 0.4),
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              title: Padding(
                padding: const EdgeInsets.only(top: 56, left: 38, right: 38),
                child: TextOverlay(
                  label: selectedPlaylist.title,
                  color: Theme.of(context).colorScheme.onPrimary,
                  maxLines: 1,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              expandedTitleScale: 1,
              collapseMode: CollapseMode.pin,
              background: SizedBox(
                height: AppConstants.height250,
                child: Padding(
                  padding: const EdgeInsets.only(top: 95, right: 20, left: 20, bottom: 80),
                  child: ResizableImageContainerWithOverlay(
                    imageUrl: selectedPlaylist.thumbnailUrl,
                    borderRadius: 10,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedPlaylist.description.trim().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextOverlay(
                          label: AppConstants.description,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: AppConstants.fontSize18,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 5),
                        ShowMoreDescription(
                          description: selectedPlaylist.description,
                          modalTitle: AppConstants.description,
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        ShareButton(
                          onShareTap: () {
                            Utils.shareYouTubePlaylist(
                              playlistId: selectedPlaylist.id,
                              playlistTitle: selectedPlaylist.title,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextOverlay(
                        label: videoCountLabel,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    ],
                  ),
                  Divider(color: Theme.of(context).colorScheme.tertiaryContainer),
                ],
              ),
            ),
          ),
          // StreamBuilder for playlist items
          StreamBuilder<List<YouTubePlaylistItemModel>>(
            stream: FirestoreServiceAPI.instance.streamPlaylistItems(
              AppConstants.kidsYoutubeChannel,
              selectedPlaylist.id,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: LoadingWidget()),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No items found')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        final youtubePlaylistItemController =
                        Get.find<YoutubePlaylistItemController>();
                        youtubePlaylistItemController.setSelectedEpisode(item);
                        Get.toNamed(Routes.getWatchYoutubeRoute());
                      },
                      child: YoutubePlaylistItemDetailsWidget(
                        youTubePlaylistItemModel: item,
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

