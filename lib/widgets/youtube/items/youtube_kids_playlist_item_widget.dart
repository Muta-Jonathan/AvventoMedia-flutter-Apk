import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../apis/firestore_service_api.dart';
import '../../../components/app_constants.dart';
import '../../../controller/youtube_playlist_controller.dart';
import '../../../models/youtubemodels/youtube_playlist_item_model.dart';
import '../../common/loading_widget.dart';
import '../../search/list_search.dart';
import '../media_rows.dart';

/// The videos of the selected Kids playlist.
class YoutubeKidsPlaylistItemWidget extends StatelessWidget {
  const YoutubeKidsPlaylistItemWidget({super.key, required this.search});

  final ListSearchHandle search;

  @override
  Widget build(BuildContext context) {
    final playlistId =
        Get.find<YoutubePlaylistController>().selectedPlaylist.value?.id;
    if (playlistId == null) {
      return const SliverToBoxAdapter(
          child: Center(child: Text('No playlist selected')));
    }

    return StreamBuilder<List<YouTubePlaylistItemModel>>(
      stream: FirestoreServiceAPI.instance
          .streamPlaylistItems(AppConstants.kidsYoutubeChannel, playlistId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
              child: Center(child: LoadingWidget()));
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: Center(child: Text('Error: ${snapshot.error}')));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const SliverToBoxAdapter(
              child: Center(child: Text('No items found')));
        }
        return PlaylistVideosList(items: items, search: search);
      },
    );
  }
}
