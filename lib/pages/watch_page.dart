import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/controller/live_tv_controller.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:floating/floating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../componets/custom_video_controls.dart';
import '../widgets/text/show_more_desc.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late ChewieController _chewieController;
  late Floating floating = Floating();
  late VideoPlayerController _videoPlayerController;
  final LiveTvController liveTvController = Get.find();

  bool isPiPMode = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(liveTvController.selectedTv.value!.streamUrl));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 10,
      allowedScreenSleep: false,
      autoPlay: true,
      showOptions: true,
      looping: false,
      isLive: true,
      autoInitialize: true,
      allowMuting: false,
      customControls: const CustomVideoControls(),
      showControlsOnInitialize: true,
      placeholder: imagePlaceHolder(context, liveTvController.selectedTv.value!.imageUrl),
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: () {
              Get.back();
              floating.enable(aspectRatio: const Rational(16,9));
            } ,
            iconData: Icons.picture_in_picture_alt_rounded,
            title: AppConstants.pip,
          ),
        ];
      },
    );

  requestPipAvailable();

  }

  Widget imagePlaceHolder(BuildContext context, String imageUrl) {
    return Stack(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
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


  void requestPipAvailable() async{
    isPiPMode = await floating.isPipAvailable;
  }

  void togglePiPMode() {
    isPiPMode = !isPiPMode;
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTv = liveTvController.selectedTv.value;
    if (!_chewieController.isFullScreen) {
      // Listen to orientation changes
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PiPSwitcher(
              childWhenEnabled: Chewie(controller: _chewieController),
              childWhenDisabled: SizedBox(
                 height: Utils.calculateHeight(context, 0.37),
                 child: Center(
                   child: Stack(
                     children: [
                       Chewie(controller: _chewieController),
                       Positioned(
                         top: 45, // Adjust the top position as needed
                         left: 5, // Adjust the left position as needed
                         child: IconButton(
                           icon: const Icon(Icons.arrow_back_sharp,color: Colors.white),
                           onPressed: () {
                             Get.back();
                           },
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     TextOverlay(label: selectedTv!.name, color: Theme.of(context).colorScheme.onPrimary, fontSize: 20, ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.share),
                        onPressed: () {
                          // Implement share functionality here
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40,),
                  ShowMoreDescription(description: selectedTv.description,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
