import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/controller/youtube_playlist_item_controller.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../componets/utils.dart';
import '../widgets/text/show_more_desc.dart';

class YoutubeWatchPage extends StatefulWidget {
  const YoutubeWatchPage({super.key});

  @override
  State<YoutubeWatchPage> createState() => _YoutubeWatchPageState();
}

class _YoutubeWatchPageState extends State<YoutubeWatchPage> {
  final YoutubePlaylistItemController youtubePlaylistItemController = Get.find();
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        playsInline: false,
        showVideoAnnotations: true,
        loop: false,
        color: 'red'
      ),
    );

    _controller.loadVideoById( videoId: youtubePlaylistItemController.selectedPlaylistItem.value!.videoId,);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = youtubePlaylistItemController.selectedPlaylistItem.value;
    final int views = int.tryParse(selectedItem!.views) ?? 0;
    String view = views == 0
        ? 'No views'
        : views == 1
        ? '$views view'
        : '$views views';
    String publishedDate = Jiffy.parseFromDateTime(selectedItem.publishedAt).fromNow();

    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body: YoutubePlayerScaffold(
        controller: _controller,
        builder: (BuildContext context, Widget player) {
         return SingleChildScrollView(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: player),
                      Positioned(
                        top: 5, // Adjust the top position as needed
                        left: 5, // Adjust the left position as needed
                        child: IconButton(
                          icon: const Icon(CupertinoIcons.chevron_back,color: Colors.white),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12,),
                        TextOverlay(label: selectedItem.title,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: AppConstants.fontSize20,
                          maxLines: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                TextOverlay(label: view,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 15,
                                ),
                                TextOverlay(
                                  label: "  $publishedDate",
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.share),
                              onPressed: () {
                                // Implement share functionality here
                                Utils.shareYouTubeVideo(selectedItem.videoId);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12,),
                        ShowMoreDescription(modalTitle: AppConstants.description,description: selectedItem.description,),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
