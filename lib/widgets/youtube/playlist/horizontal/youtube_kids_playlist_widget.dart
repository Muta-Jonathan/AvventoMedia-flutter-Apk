import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/youtube/playlist/horizontal/youtube_playlist_details_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../apis/firestore_service_api.dart';
import '../../../../routes/routes.dart';
import '../../../text/label_place_holder.dart';


class YoutubeKidsPlaylistWidget extends StatelessWidget {
  const YoutubeKidsPlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final youtubePlaylistController = Get.put(YoutubePlaylistController());
    int itemsToDisplay = 12;

    return StreamBuilder<List<YoutubePlaylistModel>>(
      stream: FirestoreServiceAPI.instance.streamPlaylists(AppConstants.kidsYoutubeChannel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: Utils.calculateAspectHeight(context, 1.25),
            child: const Center(child: LoadingWidget()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: Utils.calculateAspectHeight(context, 1.25),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final playlists = snapshot.data ?? [];

        if (playlists.isEmpty) {
          return SizedBox(
            height: Utils.calculateAspectHeight(context, 1.25),
            child: const Center(child: Text('No items found')),
          );
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: playlists.length > itemsToDisplay
                      ? itemsToDisplay + 1
                      : playlists.length,
                  itemBuilder: (context, index) {
                    if (index < itemsToDisplay && index < playlists.length) {
                      final playlist = playlists[index];
                      return GestureDetector(
                        onTap: () {
                          youtubePlaylistController.setSelectedPlaylist(playlist);
                          Get.toNamed(Routes.getYoutubeKidsPlaylistItemRoute());
                        },
                        child: YoutubePlaylistDetailsWidget(
                          youtubePlaylistModel: playlist,
                        ),
                      );
                    } else if (index == itemsToDisplay && playlists.length > itemsToDisplay) {
                      return CupertinoButton(
                        padding: const EdgeInsets.all(40),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                          child: const Icon(CupertinoIcons.forward, size: 18, color: Colors.white),
                        ),
                        onPressed: () {
                         Get.toNamed(Routes.getYoutubeKidsPlaylistRoute());
                        }
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
