import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/video_player_provider.dart';

class CustomVideoControls extends StatefulWidget {
  @override
  _CustomVideoControlsState createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  late VideoPlayerProvider videoPlayerProvider;
  bool controlsVisible = true;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    videoPlayerProvider = Provider.of<VideoPlayerProvider>(context, listen: false);

    videoPlayerProvider.chewieController.videoPlayerController.addListener(() {
      if (mounted) {
        setState(() {
          isPlaying = videoPlayerProvider.chewieController.videoPlayerController.value.isPlaying;
        });
      }
    });

    // Initialize a timer to hide controls after a certain time
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          controlsVisible = false;
        });
      }
    });
  }

  void togglePlayPause() {
    if (isPlaying) {
      videoPlayerProvider.chewieController.videoPlayerController.pause();
    } else {
      videoPlayerProvider.chewieController.videoPlayerController.play();
    }
  }

  void toggleControlsVisibility() {
    setState(() {
      controlsVisible = !controlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleControlsVisibility,
      child: Visibility(
        visible: controlsVisible,
        child: Column(
          children: [
            // Live Text
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Live",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            // Play/Pause Button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  togglePlayPause();
                },
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: isPlaying
                        ? Icon(
                      Icons.pause,
                      size: 64,
                      color: Colors.white,
                      key: ValueKey<bool>(true),
                    )
                        : Icon(
                      Icons.play_arrow,
                      size: 64,
                      color: Colors.white,
                      key: ValueKey<bool>(false),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Row with PIP, Settings, and Fullscreen Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // Implement PiP functionality here
                    // You can use a package like 'flutter_overlay_window' for PiP
                  },
                  icon: const Icon(
                    Icons.picture_in_picture,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Implement settings functionality here
                  },
                  icon: const Icon(
                    Icons.settings,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Implement fullscreen functionality here
                  },
                  icon: const Icon(
                    Icons.fullscreen,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
