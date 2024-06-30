import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/youtube/playlist/vertical/youtube_playlist_details_vertical_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controller/youtube_playlist_controller.dart';
import '../../../../routes/routes.dart';
import '../../../providers/youtube_provider.dart';

class YoutubeMusicPlaylistVerticalWidget extends StatefulWidget {
  const YoutubeMusicPlaylistVerticalWidget({super.key,});

  @override
  State<YoutubeMusicPlaylistVerticalWidget> createState() => _YoutubeMusicPlaylistVerticalWidgetState();
}

class _YoutubeMusicPlaylistVerticalWidgetState extends State<YoutubeMusicPlaylistVerticalWidget> {
  final youtubePlaylistController = Get.put(YoutubePlaylistController());

  @override
  void initState() {
    super.initState();
    // Fetch music playlists using the provider and listen to changes
    Provider.of<YoutubeProvider>(context, listen: false).fetchAllMusicPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YoutubeProvider>(
      builder: (context, youtubeProvider, child) {
        if (youtubeProvider.isLoading) {
          return const SliverToBoxAdapter(child: Center(child:LoadingWidget()));
        } else if (youtubeProvider.youtubeMusicPlaylists.isEmpty) {
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
          final item = youtubeProvider.youtubeMusicPlaylists[index];
          return buildYoutubePlaylistDetailsScreen(item);
        },
        childCount: youtubeProvider.youtubeMusicPlaylists.length,
      ),
    );
  }

  Widget buildYoutubePlaylistDetailsScreen(YoutubePlaylistModel youtubePlaylist) {
    return GestureDetector(
      onTap: () {
        // Set the selected youtube playlist using the controller
        youtubePlaylistController.setSelectedPlaylist(youtubePlaylist);
        // Navigate to the "YoutubePlaylistPage"
        Get.toNamed(Routes.getYoutubeMusicPlaylistItemRoute());
      },
      child: YoutubePlaylistDetailsVerticalWidget(youtubePlaylistModel: youtubePlaylist,),
    );
  }
}
