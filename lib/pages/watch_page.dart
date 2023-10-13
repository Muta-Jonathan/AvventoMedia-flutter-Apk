import 'package:avvento_radio/componets/utils.dart';
import 'package:chewie/chewie.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  final String videoUrl = "https://3abn-live.akamaized.net/hls/live/2010544/International/master.m3u8";
  late ChewieController _chewieController;
  late Floating floating = Floating();
  late VideoPlayerController _videoPlayerController;

  bool isPiPMode = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false,
      autoPlay: false,
      showOptions: false,
      looping: false,
      isLive: true,
      autoInitialize: true,
      showControlsOnInitialize: true,


    );

  requestPipAvailable();

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            PiPSwitcher(
              childWhenEnabled: Chewie(controller: _chewieController!),
              childWhenDisabled: SizedBox(
                 height: Utils.calculateHeight(context, 0.37),
                 child: Chewie(controller: _chewieController),
               ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Video Title',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          // Implement share functionality here
                        },
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: isPiPMode ? () => floating.enable(aspectRatio: const Rational(16,9)) : null,
                            icon: const Icon(
                              Icons.picture_in_picture,
                              size: 32,
                              color: Colors.white,
                            ),
                          )

                        ],
                      ),
                    ],
                  ),
                  const Text(
                    'Video Description goes here. You can make it as long as you need.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
