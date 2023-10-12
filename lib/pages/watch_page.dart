import 'package:avvento_radio/componets/utils.dart';
import 'package:flutter/material.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  bool fullscreen = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
         const Padding(
           padding: EdgeInsets.only(top: 40.0),
           child: YoYoPlayer(
                  aspectRatio: 16 / 9,
                  url: "https://3abn-live.akamaized.net/hls/live/2010544/International/master.m3u8",
                videoStyle: VideoStyle(
                  showLiveDirectButton: true,
                ),
                  videoLoadingStyle: VideoLoadingStyle(),
                  allowCacheFile: true,

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
                    const Column(
                      children: [
                        Icon(Icons.favorite),
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
    );
  }
}
