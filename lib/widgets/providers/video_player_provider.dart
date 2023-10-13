import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProvider extends ChangeNotifier {
  late ChewieController chewieController;
  late Floating floating = Floating();
  late VideoPlayerController videoPlayerController;

  bool isPiPMode = false;

  VideoPlayerProvider(String videoUrl) {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    videoPlayerController.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false,
      autoPlay: false,
      showOptions: false,
      looping: false,
      isLive: true,

    );
    notifyListeners();
  }



  void requestPipAvailable() async{
    isPiPMode = await floating.isPipAvailable;
  }

  void togglePiPMode() {
    isPiPMode = !isPiPMode;
    notifyListeners();
  }

}
