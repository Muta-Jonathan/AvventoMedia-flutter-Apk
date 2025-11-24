import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/hightlights/hightlight_details_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apis/firestore_service_api.dart';
import '../../controller/youtube_playlist_controller.dart';
import '../../controller/youtube_playlist_item_controller.dart';
import '../../models/highlightmodel/highlight_model.dart';
import '../../routes/routes.dart';

class HightlightsWidget extends StatefulWidget {
  const HightlightsWidget({super.key});

  @override
  State<HightlightsWidget> createState() => _HightlightsWidget();
}

class _HightlightsWidget extends State<HightlightsWidget> {
  final _highlightsAPI = Get.put(FirestoreServiceAPI());
  final youtubePlaylistItemController = Get.put(YoutubePlaylistItemController());
  final youtubePlaylistController = Get.put(YoutubePlaylistController());

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.46),
      child: Column(
        children: [
          Expanded(child: buildListView(context)),
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return StreamBuilder(
        stream: _highlightsAPI.fetchHighlights(),
        builder: (_, snapshot)  {
          if (snapshot.hasData) {
            List highlightList = snapshot.data!.docs;
            if (highlightList.isNotEmpty) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: highlightList.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot documentSnapshot = highlightList[index];

                  HighlightModel highlightModel = HighlightModel.fromSnapShot(documentSnapshot);

                  return  buildHighlightDetailsScreen(highlightModel);
                },
              );
            } else {
              return const LoadingWidget();
            }
          } else {
            return const LoadingWidget();
          }
        });

  }

  Widget buildHighlightDetailsScreen(HighlightModel highlightModel) {
    return  GestureDetector(
        onTap: () {
          if (highlightModel.youtubePlaylistItem != null) {
            // Set the selected youtube playlist using the controller
            youtubePlaylistItemController.setSelectedEpisode(highlightModel.youtubePlaylistItem);
            // Navigate to the "YoutubePlaylistPage"
            Get.toNamed(Routes.getWatchYoutubeRoute());
          } else if (highlightModel.youtubePlaylist != null ) {
            // Set the selected youtube playlist using the controller
            youtubePlaylistController.setSelectedPlaylist(highlightModel.youtubePlaylist);
            if (highlightModel.type == AppConstants.avventoMusic) {
              // Navigate to the "music YoutubePlaylistPage"
              Get.toNamed(Routes.getYoutubeMusicPlaylistItemRoute());
            } else  if (highlightModel.type == AppConstants.avventoKids) {
              // Navigate to the "Kids YoutubePlaylistPage"
              Get.toNamed(Routes.getYoutubeKidsPlaylistItemRoute());
            } else {
              // Navigate to the "Kids YoutubePlaylistPage"
              Get.toNamed(Routes.getYoutubeMainPlaylistItemRoute());
            }
          }
        },
        child: HightlightsDetailsWidget(highlightModel: highlightModel,)
    );
  }


}
