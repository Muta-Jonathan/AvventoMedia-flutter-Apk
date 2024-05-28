import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/controller/live_tv_controller.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:floating/floating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../componets/utils.dart';
import '../widgets/text/show_more_desc.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late Floating floating = Floating();
  final LiveTvController liveTvController = Get.find();
  late BetterPlayerController _betterPlayerController;
  final GlobalKey _betterPlayerKey = GlobalKey();
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      liveTvController.selectedTv.value!.streamUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: liveTvController.selectedTv.value!.name,
        author: "3ABN & Avvento",
        imageUrl: liveTvController.selectedTv.value!.imageUrl,
        activityName: "MainActivity",
      ),
      liveStream: true,
      drmConfiguration: BetterPlayerDrmConfiguration(
        drmType: BetterPlayerDrmType.token,
        token: "Bearer=token",
      ),
    );
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          // placeholder: imagePlaceHolder(context, liveTvController.selectedTv.value!.imageUrl),
          autoPlay: true,
          allowedScreenSleep: false,
          expandToFill: false,
          fit: BoxFit.fitHeight,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControlsOnInitialize: true,
            enableSubtitles: false,
            enablePlayPause: true,
            enableOverflowMenu: true,
            enablePip: true,
            playerTheme: BetterPlayerTheme.material,
            loadingWidget: const LoadingWidget(),
            overflowMenuCustomItems: [
              BetterPlayerOverflowMenuItem(
                Icons.picture_in_picture_alt_rounded,
                AppConstants.pip,
                    () => _betterPlayerController.enablePictureInPicture(_betterPlayerKey)
              )
            ],
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
  }

  Widget imagePlaceHolder(BuildContext context, String imageUrl) {
    return Stack(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => const LoadingWidget(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.cover,
        ),
        // Overlay with 45% black background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.45),
        ),
      ],
    );
  }

  @override
  void dispose() {
   _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTv = liveTvController.selectedTv.value;

    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child:  BetterPlayer(
                      controller: _betterPlayerController,
                      key: _betterPlayerKey,
                    ),
                  ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                       TextOverlay(label: selectedTv!.name, color: Theme.of(context).colorScheme.onPrimary, fontSize: AppConstants.fontSize20, ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.share),
                          onPressed: () {
                            // Implement share functionality here
                            Utils.share("${AppConstants.shareTvStream} _ ${liveTvController.selectedTv.value!.name} , \n ${AppConstants.webTvUrl}");
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12,),
                    ShowMoreDescription(description: selectedTv.description,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
