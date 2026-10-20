import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../apis/firestore_service_api.dart';
import '../../../../controller/youtube_playlist_controller.dart';
import '../../../../models/youtubemodels/youtube_playlist_model.dart';
import '../../../common/loading_widget.dart';
import '../../../search/list_search.dart';
import '../../media_rows.dart';

/// A channel's playlists, narrowed and ordered by the page's search.
/// Tapping one opens it at [itemRoute].
class ChannelPlaylistsList extends StatelessWidget {
  const ChannelPlaylistsList({
    super.key,
    required this.channel,
    required this.itemRoute,
    required this.search,
  });

  final String channel;
  final String itemRoute;
  final ListSearchHandle search;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(YoutubePlaylistController());

    return StreamBuilder<List<YoutubePlaylistModel>>(
      stream: FirestoreServiceAPI.instance.streamPlaylists(channel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
              child: Center(child: LoadingWidget()));
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: Center(child: Text('Error: ${snapshot.error}')));
        }
        final playlists = snapshot.data ?? [];
        if (playlists.isEmpty) {
          return const SliverToBoxAdapter(
              child: Center(child: Text('No items found')));
        }

        return ListSearchList<YoutubePlaylistModel>(
          items: playlists,
          search: search,
          titleOf: (p) => p.title,
          dateOf: (p) => p.publishedAt,
          itemBuilder: (context, playlist, query) => playlistRow(
            playlist,
            query: query,
            onTap: () {
              controller.setSelectedPlaylist(playlist);
              Get.toNamed(itemRoute);
            },
          ),
        );
      },
    );
  }
}
