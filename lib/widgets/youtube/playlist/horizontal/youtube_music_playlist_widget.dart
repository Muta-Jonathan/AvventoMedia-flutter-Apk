import 'dart:math';

import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/providers/youtube_provider.dart';
import 'package:avvento_media/widgets/youtube/playlist/horizontal/youtube_playlist_details_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../routes/routes.dart';
import '../../../common/no_internet_widget.dart';
import '../../../text/label_place_holder.dart';


class YoutubeMusicPlaylistWidget extends StatefulWidget {
  const YoutubeMusicPlaylistWidget({super.key});

  @override
  State<YoutubeMusicPlaylistWidget> createState() => _YoutubeMusicPlaylistWidget();
}

class _YoutubeMusicPlaylistWidget extends State<YoutubeMusicPlaylistWidget> {
  final youtubePlaylistController = Get.put(YoutubePlaylistController());
  int itemsToDisplay = 12;
  bool _isConnected = true; // Tracks network status

  @override
  void initState() {
    super.initState();
    // Fetch music playlist using the provider and listen to changes
    Provider.of<YoutubeProvider>(context, listen: false).fetchAllMusicPlaylists();
    // Check initial connectivity and update state
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final youtubeProvider = Provider.of<YoutubeProvider>(context);

    if (!_isConnected) {
      return const NoConnectionMessage();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.25),
      child: Column(
        children: [
          LabelPlaceHolder(title: AppConstants.avventoMusic,titleFontSize: 18, moreIcon: true, onMoreTap: () => Get.toNamed(Routes.getYoutubeMusicPlaylistRoute(),)),
          Expanded(child: buildListView(context, youtubeProvider),)
        ],
      ),
    );
  }


  Widget buildListView(BuildContext context, YoutubeProvider youtubeProvider) {
    final int itemCount = youtubeProvider.youtubeMusicPlaylists.length;

    if (itemCount > 0) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount > 0 ? min(itemsToDisplay, itemCount) + 1 : 0,
        itemBuilder: (BuildContext context, int index) {
          if (index < min(itemsToDisplay, itemCount)) {
            return buildYoutubeMusicPlaylistDetailsScreen(youtubeProvider.youtubeMusicPlaylists[index]);
          } else if (index == min(itemsToDisplay, itemCount)) {
            return itemCount > itemsToDisplay ? buildShowMoreItem(context) : const SizedBox.shrink();
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    } else {
      return const LoadingWidget();
    }
  }


  Widget buildShowMoreItem(BuildContext context) {
    return CupertinoButton(
        padding: const EdgeInsets.all(40.0), // Adjust as needed
        child: CircleAvatar(
          radius: 22, // Adjust the radius to fit the icon size
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: const Icon(
            CupertinoIcons.forward, // Cupertino "forward" icon
            size: 18,
            color: Colors.white, // Customize the color
          ),
        ),
        onPressed: () {
          // Go to the full playlist page
          Get.toNamed(Routes.getYoutubeMusicPlaylistRoute());
        },
    );
  }

  Widget buildYoutubeMusicPlaylistDetailsScreen(YoutubePlaylistModel youtubePlaylistModel) {
    return GestureDetector(
      onTap: () {
        // Set the selected youtube playlist using the controller
        youtubePlaylistController.setSelectedPlaylist(youtubePlaylistModel);
        // Navigate to the "YoutubePlaylistPage"
        Get.toNamed(Routes.getYoutubeMusicPlaylistItemRoute());
      },
        child: YoutubePlaylistDetailsWidget(youtubePlaylistModel: youtubePlaylistModel,),
    );
  }
}
