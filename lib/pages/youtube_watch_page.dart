import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/youtube_playlist_item_controller.dart';
import 'package:avvento_media/widgets/common/share_button.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../components/utils.dart';
import '../widgets/text/show_more_desc.dart';

class YoutubeWatchPage extends StatefulWidget {
  const YoutubeWatchPage({super.key});

  @override
  State<YoutubeWatchPage> createState() => _YoutubeWatchPageState();
}

class _YoutubeWatchPageState extends State<YoutubeWatchPage> {
  final YoutubePlaylistItemController youtubePlaylistItemController = Get.find();
  late YoutubePlayerController _controller;
  bool isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    final selected = youtubePlaylistItemController.selectedPlaylistItem.value!;

    _controller = YoutubePlayerController(
      initialVideoId: selected.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
        forceHD: false,
        enableCaption: false,
        isLive: selected.liveBroadcastContent == 'live',
        useHybridComposition: true,
      ),
    );

    // Allow immersive fullscreen when rotated
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = youtubePlaylistItemController.selectedPlaylistItem.value;
    final int views = int.tryParse(selectedItem!.views) ?? 0;
    String view = Utils.formatViews(views);
    String publishedDate = Jiffy.parseFromDateTime(selectedItem.publishedAt).fromNow();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,

          ),
            builder: (context, player) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SafeArea(
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: player,
                        ),
                        Positioned(
                          top: 5,
                          left: 5,
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.chevron_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ],
                    ),
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
                        TextOverlay(label: 'from  ${youtubePlaylistItemController.selectedPlaylistItem.value!.channelTitle}',
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 15,
                        ),
                        const SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: view == 'No views' ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (youtubePlaylistItemController.selectedPlaylistItem.value!.liveBroadcastContent == 'live' ||
                                youtubePlaylistItemController.selectedPlaylistItem.value!.liveBroadcastContent == 'upcoming' ||
                                view == 'No views') ?
                            const SizedBox.shrink() :
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
                            ShareButton(onShareTap: (){ Utils.shareYouTubeVideo(selectedItem.videoId); }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ShowMoreDescription(
                          modalTitle: AppConstants.description,
                          description: selectedItem.description,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
