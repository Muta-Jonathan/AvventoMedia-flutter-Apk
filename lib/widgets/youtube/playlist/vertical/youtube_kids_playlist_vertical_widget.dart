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

class YoutubeKidsPlaylistVerticalWidget extends StatefulWidget {
  const  YoutubeKidsPlaylistVerticalWidget({super.key,});

  @override
   YoutubeKidsPlaylistVerticalWidgetState createState() =>  YoutubeKidsPlaylistVerticalWidgetState();
}

class  YoutubeKidsPlaylistVerticalWidgetState extends State< YoutubeKidsPlaylistVerticalWidget> {
  final youtubePlaylistController = Get.put(YoutubePlaylistController());

  @override
  void initState() {
    super.initState();
    // Fetch kids playlists using the provider and listen to changes
    Provider.of<YoutubeProvider>(context, listen: false).fetchAllKidsPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YoutubeProvider>(
      builder: (context, youtubeProvider, child) {
        if (youtubeProvider.isLoading) {
          return const SliverToBoxAdapter(child: Center(child:LoadingWidget()));
        } else if (youtubeProvider.youtubeKidsPlaylists.isEmpty) {
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
          final item = youtubeProvider.youtubeKidsPlaylists[index];
          return buildKidsYoutubePlaylistDetailsScreen(item);
        },
        childCount: youtubeProvider.youtubeKidsPlaylists.length,
      ),
    );
  }

  Widget buildKidsYoutubePlaylistDetailsScreen(YoutubePlaylistModel youtubePlaylist) {
    return GestureDetector(
      onTap: () {
        // Set the selected youtube playlist using the controller
        youtubePlaylistController.setSelectedPlaylist(youtubePlaylist);
        // Navigate to the "YoutubePlaylistPage"
        Get.toNamed(Routes.getYoutubeKidsPlaylistItemRoute());
      },
      child: YoutubePlaylistDetailsVerticalWidget(youtubePlaylistModel: youtubePlaylist,),
    );
  }
}
