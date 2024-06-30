import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../widgets/images/resizable_image_widget_2.dart';
import '../widgets/providers/youtube_provider.dart';
import '../widgets/text/show_more_desc.dart';
import '../widgets/youtube/items/youtube_music_playlist_item_widget.dart';

class YoutubeMusicPlaylistItemPage extends StatefulWidget {
  const YoutubeMusicPlaylistItemPage({super.key});

  @override
  State<YoutubeMusicPlaylistItemPage> createState() => _YoutubeMusicPlaylistItemPageState();
}

class _YoutubeMusicPlaylistItemPageState extends State<YoutubeMusicPlaylistItemPage> {
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
      await Provider.of<YoutubeProvider>(context, listen: false).fetchAllMusicPlaylistItem(playlistId:  youtubePlaylistController.selectedPlaylist.value!.id);

      await Future.delayed(const Duration(seconds: 2)); // Simulate data loading
    }
    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.orange,
          onRefresh: refreshData,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor:   Theme.of(context).colorScheme.surface,
                iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
                expandedHeight: Utils.calculateHeight(context, 0.4),
                floating: false,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(CupertinoIcons.share,color: Theme.of(context).colorScheme.onPrimary,),
                    onPressed: () {
                      Utils.shareYouTubePlaylist(playlistId: youtubePlaylistController.selectedPlaylist.value!.id, playlistTitle:youtubePlaylistController.selectedPlaylist.value!.title);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.blurBackground
                  ],
                  title: TextOverlay(
                    label: youtubePlaylistController.selectedPlaylist.value!.title,
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
              const YoutubeMusicPlaylistItemWidget(),
            ],
          ),
      ),
    );
  }
}

