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


class YoutubeKidsPlaylistWidget extends StatefulWidget {
  const YoutubeKidsPlaylistWidget({super.key});

  @override
  State<YoutubeKidsPlaylistWidget> createState() => _YoutubeKidsPlaylistWidget();
}

class _YoutubeKidsPlaylistWidget extends State<YoutubeKidsPlaylistWidget> {
  final youtubePlaylistController = Get.put(YoutubePlaylistController());
  int itemsToDisplay = 12;
  bool _isConnected = true; // Tracks network status

  @override
  void initState() {
    super.initState();
    // Fetch Kids playlist using the provider and listen to changes
    Provider.of<YoutubeProvider>(context, listen: false).fetchAllKidsPlaylists();
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
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.25),
      child: Column(
        children: [
          LabelPlaceHolder(
            title: AppConstants.avventoKids,
            titleFontSize: 18,
            moreIcon: true,
            onMoreTap: () => Get.toNamed(Routes.getYoutubeKidsPlaylistRoute()),
          ),
          Expanded(
            child: buildListView(context, youtubeProvider),
          ),
        ],
      ),
    );
  }



  Widget buildListView(BuildContext context, YoutubeProvider youtubeProvider) {
    final int itemCount = youtubeProvider.youtubeKidsPlaylists.length;

    if (itemCount > 0) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount > 0 ? min(itemsToDisplay, itemCount) + 1 : 0,
        itemBuilder: (BuildContext context, int index) {
          if (index < min(itemsToDisplay, itemCount)) {
            return buildYoutubeKidsPlaylistDetailsScreen(youtubeProvider.youtubeKidsPlaylists[index]);
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
          Get.toNamed(Routes.getYoutubeKidsPlaylistRoute());
        },
    );
  }

  Widget buildYoutubeKidsPlaylistDetailsScreen(YoutubePlaylistModel youtubePlaylistModel) {
    return GestureDetector(
      onTap: () {
        // Set the selected youtube playlist using the controller
        youtubePlaylistController.setSelectedPlaylist(youtubePlaylistModel);
        // Navigate to the "YoutubePlaylistPage"
        Get.toNamed(Routes.getYoutubeKidsPlaylistItemRoute());
      },
        child: YoutubePlaylistDetailsWidget(youtubePlaylistModel: youtubePlaylistModel,),
    );
  }
}
