import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../widgets/common/share_button.dart';
import '../widgets/images/resizable_image_widget_2.dart';
import '../widgets/providers/youtube_provider.dart';
import '../widgets/text/show_more_desc.dart';
import '../widgets/youtube/items/youtube_main_playlist_item_widget.dart';

class YoutubeMainPlaylistItemPage extends StatefulWidget {
  const YoutubeMainPlaylistItemPage({super.key});

  @override
  State<YoutubeMainPlaylistItemPage> createState() => _YoutubePlaylistItemPageState();
}

class _YoutubePlaylistItemPageState extends State<YoutubeMainPlaylistItemPage> {
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
    final int itemCount = youtubePlaylistController.selectedPlaylist.value!.itemCount;
    String videoCountLabel = itemCount == 1 ? '$itemCount video' : '$itemCount videos';

    Future<void> refreshData() async {
      // Fetch fresh data for a specific playlist
      Provider.of<YoutubeProvider>(context, listen: false).streamMainPlaylistItems(playlistId:  youtubePlaylistController.selectedPlaylist.value!.id);

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
                  title: Padding(
                    padding: const EdgeInsets.only(top: 56,left: 38, right: 38),
                    child: TextOverlay(
                      label: youtubePlaylistController.selectedPlaylist.value!.title,
                      color: Theme.of(context).colorScheme.onPrimary,
                      maxLines: 2,
                      fontSize: 18,
                    ),
                  ),
                  centerTitle: true,
                  expandedTitleScale: 1,
                  collapseMode: CollapseMode.pin,
                  background: SizedBox(
                    height: AppConstants.height250,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 95, right: 20, left: 20, bottom: 80),
                      child: ResizableImageContainerWithOverlay(
                        imageUrl: youtubePlaylistController.selectedPlaylist.value!.thumbnailUrl,
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
                      youtubePlaylistController.selectedPlaylist.value?.description.trim() != '' ?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextOverlay(label: AppConstants.description, color: Theme.of(context).colorScheme.onPrimary,fontSize: AppConstants.fontSize18,fontWeight: FontWeight.bold,),
                          const SizedBox(height: 5),
                          ShowMoreDescription(description: youtubePlaylistController.selectedPlaylist.value!.description,modalTitle: AppConstants.description,),
                        ],
                      ) : const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ShareButton(onShareTap: (){ Utils.shareYouTubePlaylist(playlistId: youtubePlaylistController.selectedPlaylist.value!.id, playlistTitle:youtubePlaylistController.selectedPlaylist.value!.title); }),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextOverlay(label: videoCountLabel, color: Theme.of(context).colorScheme.onPrimary,fontSize: 15),
                        ],
                      ),
                      Divider(color: Theme.of(context).colorScheme.tertiaryContainer,),
                    ],
                  ),
                ),
              ),
              const YoutubeMainPlaylistItemWidget(),
            ],
          ),
      ),
    );
  }
}

