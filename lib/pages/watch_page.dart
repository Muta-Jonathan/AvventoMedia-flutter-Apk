import 'package:avvento_radio/componets/utils.dart';
import 'package:chewie/chewie.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../widgets/providers/video_player_provider.dart';
import '../widgets/video/custom_video_controls.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late VideoPlayerProvider videoPlayerProvider;
  final String videoUrl = "https://3abn-live.akamaized.net/hls/live/2010544/International/master.m3u8";
  late ChewieController _chewieController;


  @override
  void initState() {
    super.initState();
    videoPlayerProvider = Provider.of<VideoPlayerProvider>(context, listen: false);
    // videoPlayerProvider = VideoPlayerProvider(videoUrl);

    // Initialize ChewieController using the provider's chewieController
    _chewieController = videoPlayerProvider.chewieController;
    videoPlayerProvider.requestPipAvailable();
  }


  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
    videoPlayerProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            PiPSwitcher(
              childWhenEnabled: Chewie(controller: _chewieController),
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
                            onPressed: videoPlayerProvider.isPiPMode ? () => videoPlayerProvider.floating.enable(aspectRatio: const Rational(16,9)) : null,
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
