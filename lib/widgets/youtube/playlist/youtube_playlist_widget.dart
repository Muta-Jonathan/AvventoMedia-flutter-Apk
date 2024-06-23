import 'dart:math';

import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/providers/youtube_provider.dart';
import 'package:avvento_media/widgets/youtube/playlist/youtube_playlist_details_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../routes/routes.dart';
import '../../text/label_place_holder.dart';


class YoutubePlaylistWidget extends StatefulWidget {
  const YoutubePlaylistWidget({super.key});

  @override
  State<YoutubePlaylistWidget> createState() => _YoutubePlaylistWidget();
}

class _YoutubePlaylistWidget extends State<YoutubePlaylistWidget> {
  final youtubePlaylistController = Get.put(YoutubePlaylistController());
  int itemsToDisplay = 5;

  @override
  void initState() {
    super.initState();
    // Fetch musicplaylist using the provider and listen to changes
    Provider.of<YoutubeProvider>(context, listen: false).fetchAllMusicPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final youtubeProvider = Provider.of<YoutubeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.3),
      child: Column(
        children: [
          const LabelPlaceHolder(title: AppConstants.avventoMusic,titleFontSize: 18),
          const SizedBox(height: 10),
          Expanded(child: buildListView(context, youtubeProvider),)
        ],
      ),
    );
  }


  Widget buildListView(BuildContext context, YoutubeProvider youtubeProvider) {
    final int itemCount = youtubeProvider.youtubePlaylists.length;

    if (itemCount > 0) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount > 0 ? min(itemsToDisplay, itemCount) + 1 : 0,
        itemBuilder: (BuildContext context, int index) {
          if (index < min(itemsToDisplay, itemCount)) {
            return buildYoutubeMusicPlaylistDetailsScreen(youtubeProvider.youtubePlaylists[index]);
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
    return Padding(
      padding: const EdgeInsets.all(8.0), // Adjust as needed
      child: CupertinoButton(
        padding: const EdgeInsets.all(8.0), // Adjust as needed
        child: Icon(
          CupertinoIcons.forward, // Cupertino "forward" icon
          size: 32,
          color: Theme.of(context).colorScheme.onPrimary, // Customize the color
        ),
        onPressed: () {
          setState(() {
            // Increment the number of items to display when "Show More" is clicked
            itemsToDisplay += 5;
          });
        },
      ),
    );
  }

  Widget buildYoutubeMusicPlaylistDetailsScreen(YoutubePlaylistModel youtubePlaylistModel) {
    return GestureDetector(
      onTap: () {
        // Set the selected youtube playlist using the controller
        youtubePlaylistController.setSelectedEpisode(youtubePlaylistModel);
        // Navigate to the "YoutubePlaylistPage"
        Get.toNamed(Routes.getYoutubePlaylistRoute());
      },
        child: YoutubePlaylistDetailsWidget(youtubePlaylistModel: youtubePlaylistModel,),
    );
  }
}
