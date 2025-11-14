import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/youtube/playlist/vertical/youtube_playlist_details_vertical_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../apis/firestore_service_api.dart';
import '../../../../components/app_constants.dart';
import '../../../../controller/youtube_playlist_controller.dart';
import '../../../../routes/routes.dart';
class YoutubeMainPlaylistVerticalWidget extends StatefulWidget {
  const YoutubeMainPlaylistVerticalWidget({super.key});

  @override
  YoutubeMainPlaylistVerticalWidgetState createState() =>
      YoutubeMainPlaylistVerticalWidgetState();
}

class YoutubeMainPlaylistVerticalWidgetState
    extends State<YoutubeMainPlaylistVerticalWidget> {
  final youtubePlaylistController = Get.put(YoutubePlaylistController());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<YoutubePlaylistModel>>(
      stream: FirestoreServiceAPI.instance
          .streamPlaylists(AppConstants.avventoMainChannel),
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

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              final playlist = playlists[index];
              return GestureDetector(
                onTap: () {
                  youtubePlaylistController.setSelectedPlaylist(playlist);
                  Get.toNamed(Routes.getYoutubeMainPlaylistItemRoute());
                },
                child: YoutubePlaylistDetailsVerticalWidget(
                  youtubePlaylistModel: playlist,
                ),
              );
            },
            childCount: playlists.length,
          ),
        );
      },
    );
  }
}
