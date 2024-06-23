import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/controller/youtube_playlist_item_controller.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  final Key _youtubeKey =  const Key('youtube_key');
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    // Set initial orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }


  void _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: youtubePlaylistItemController.selectedPlaylistItem.value!
          .videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: false,
        showLiveFullscreenButton: false,
      ),
    );

    _controller.addListener(() {
      final isCurrentlyFullScreen = _controller.value.isFullScreen;
      if (isFullScreen != isCurrentlyFullScreen) {
        setState(() {
          isFullScreen = isCurrentlyFullScreen;
        });
        _handleFullScreenChange();
      }
    });
  }

  void _handleFullScreenChange() {
    if (isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  void _exitFullscreenAndSetPortrait() {
    _controller.toggleFullScreenMode(); // Exit fullscreen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]); // Set orientation to portrait
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = youtubePlaylistItemController.selectedPlaylistItem.value;

    return WillPopScope(
      onWillPop: () async {
        if (isFullScreen) {
          _exitFullscreenAndSetPortrait(); // Handle back button to exit fullscreen
          return false; // Prevent app from closing
        }
        return true; // Allow app to close if not in fullscreen
      },
      child: Scaffold(
        backgroundColor:   Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: isFullScreen ? MediaQuery.of(context).size.aspectRatio*1.08 : 16 / 9,
                      child: Center(
                        child: YoutubePlayer(
                          controller: _controller,
                          key: _youtubeKey,
                          showVideoProgressIndicator: true,
                          bufferIndicator: const LoadingWidget(),
                          progressIndicatorColor: Colors.orange,
                          progressColors: const ProgressBarColors(
                            playedColor: Colors.red,
                            handleColor: Colors.red,
                          ),
                          liveUIColor: Colors.red,
                        ),
                      ),),
                    !isFullScreen ?
                    Positioned(
                      top: 5, // Adjust the top position as needed
                      left: 5, // Adjust the left position as needed
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.chevron_back,color: Colors.white),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ) :
                    const SizedBox.shrink(),
                  ],
                ),
                !isFullScreen ?
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                         SizedBox(width: Utils.calculateWidth(context, 0.8),child: TextOverlay(label: selectedItem!.title, color: Theme.of(context).colorScheme.onPrimary, fontSize: AppConstants.fontSize20,)),
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
                ) :
                const SizedBox.shrink()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
