import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/youtube/items/youtube_playlist_item_details_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../apis/firestore_service_api.dart';
import '../../../controller/youtube_playlist_controller.dart';
import '../../../controller/youtube_playlist_item_controller.dart';
import '../../../routes/routes.dart';

class YoutubeKidsPlaylistItemWidget extends StatelessWidget {
  const YoutubeKidsPlaylistItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final youtubePlaylistItemController = Get.put(YoutubePlaylistItemController());
    final youtubePlaylistController = Get.find<YoutubePlaylistController>();

    // Get the selected playlist ID
    final playlistId = youtubePlaylistController.selectedPlaylist.value?.id;

    if (playlistId == null) {
      return const SliverToBoxAdapter(child: Center(child: Text('No playlist selected')));
    }

    return StreamBuilder<List<YouTubePlaylistItemModel>>(
      stream: FirestoreServiceAPI.instance.streamPlaylistItems(
        AppConstants.kidsYoutubeChannel,
        playlistId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: LoadingWidget()));
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}')));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Text('No items found')));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
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
    );
  }
}
