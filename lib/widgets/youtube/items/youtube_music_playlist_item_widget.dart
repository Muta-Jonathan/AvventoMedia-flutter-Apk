import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controller/youtube_playlist_controller.dart';
import '../../common/loading_widget.dart';
import '../../providers/youtube_provider.dart';
import '../../search/list_search.dart';
import '../media_rows.dart';

/// The videos of the selected Music playlist.
class YoutubeMusicPlaylistItemWidget extends StatefulWidget {
  const YoutubeMusicPlaylistItemWidget({super.key, required this.search});

  final ListSearchHandle search;

  @override
  YoutubeMusicPlaylistItemWidgetState createState() =>
      YoutubeMusicPlaylistItemWidgetState();
}

class YoutubeMusicPlaylistItemWidgetState
    extends State<YoutubeMusicPlaylistItemWidget> {
  final YoutubePlaylistController youtubePlaylistController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Load the playlist's videos and follow changes.
        Provider.of<YoutubeProvider>(context, listen: false)
            .streamMusicPlaylistItems(
                playlistId:
                    youtubePlaylistController.selectedPlaylist.value!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YoutubeProvider>(
      builder: (context, youtubeProvider, child) {
        if (youtubeProvider.isLoading) {
          return const SliverToBoxAdapter(
              child: Center(child: LoadingWidget()));
        } else if (youtubeProvider.youtubeMusicPlaylistItems.isEmpty) {
          return const SliverToBoxAdapter(
              child: Center(child: Text('No items found')));
        }
        return PlaylistVideosList(
            items: youtubeProvider.youtubeMusicPlaylistItems,
            search: widget.search);
      },
    );
  }
}
