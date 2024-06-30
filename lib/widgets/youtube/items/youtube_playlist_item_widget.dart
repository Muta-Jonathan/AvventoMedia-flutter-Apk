import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/youtube/items/youtube_playlist_item_details_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controller/youtube_playlist_controller.dart';
import '../../../controller/youtube_playlist_item_controller.dart';
import '../../../routes/routes.dart';
import '../../providers/youtube_provider.dart';

class YoutubePlaylistItemWidget extends StatefulWidget {
  const YoutubePlaylistItemWidget({super.key,});

  @override
  YoutubePlaylistItemWidgetState createState() => YoutubePlaylistItemWidgetState();
}

class YoutubePlaylistItemWidgetState extends State<YoutubePlaylistItemWidget> {
  final youtubePlaylistItemController = Get.put(YoutubePlaylistItemController());
  final YoutubePlaylistController youtubePlaylistController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Fetch music playlist item using the provider and listen to changes
        Provider.of<YoutubeProvider>(context, listen: false).fetchAllMusicPlaylistItem(playlistId: youtubePlaylistController.selectedPlaylist.value!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YoutubeProvider>(
      builder: (context, youtubeProvider, child) {
        if (youtubeProvider.isLoading) {
          return const SliverToBoxAdapter(child: Center(child:LoadingWidget()));
        } else if (youtubeProvider.youtubePlaylistItems.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Text('No items found')));
        } else {
          return buildSliverList(youtubeProvider);
        }
      },
    );
  }
  Widget buildSliverList(YoutubeProvider youtubeProvider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          final item = youtubeProvider.youtubePlaylistItems[index];
          return buildYoutubePlaylistItemDetailsScreen(item);
        },
        childCount: youtubeProvider.youtubePlaylistItems.length,
      ),
    );
  }

  Widget buildYoutubePlaylistItemDetailsScreen(YouTubePlaylistItemModel youtubePlaylistItem) {
    return GestureDetector(
      onTap: () {
        // Set the selected youtube playlist using the controller
        youtubePlaylistItemController.setSelectedEpisode(youtubePlaylistItem);
        // Navigate to the "YoutubePlaylistPage"
        Get.toNamed(Routes.getWatchYoutubeRoute());
      },
      child: YoutubePlaylistItemDetailsWidget(youTubePlaylistItemModel: youtubePlaylistItem,),
    );
  }
}
