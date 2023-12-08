import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPlayerControlsWidget extends StatefulWidget {
  final BetterPlayerController? controller;
  final GlobalKey betterPlayerKey;

  const CustomPlayerControlsWidget({
    Key? key,
    this.controller,
    required this.betterPlayerKey,
  }) : super(key: key);

  @override
  _CustomPlayerControlsWidgetState createState() => _CustomPlayerControlsWidgetState();
}

class _CustomPlayerControlsWidgetState extends State<CustomPlayerControlsWidget> with SingleTickerProviderStateMixin {
late AnimationController _animationController;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controlVisibility();
  }

    void _onTap() {
    widget.controller?.setControlsVisibility(true);
    if (widget.controller!.isPlaying()!) {
      widget.controller?.pause();
      _animationController.reverse(); // Reverse the animation for pause
    } else {
      widget.controller?.play();
      _animationController.forward(); // Start the animation for play
    }
  }

  void _controlVisibility() {
    widget.controller?.setControlsVisibility(true);
    Future.delayed(const Duration(seconds: 7))
          .then((value) => widget.controller?.setControlsVisibility(false));
  }

String _formatDuration(Duration? duration) {
    if (duration != null) {
      String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } else {
      return '00:00';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: false,
        stream: widget.controller?.controlsVisibilityStream,
        builder: (context, snapshot) {
          bool isPlaying = widget.controller!.isPlaying() ?? false;
          return  InkWell(
            onTap: _controlVisibility,
            child: Visibility(
              visible: snapshot.data!,
              child: Stack(
                children: [
                  Positioned(
                      child:Center(
                        child: FloatingActionButton(
                          onPressed: _onTap,
                          backgroundColor: Colors.black.withOpacity(0.4),
                          child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: _animationController,
                            color: Colors.white,
                            size: 45.0,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 8,
                    child: ValueListenableBuilder(
                      valueListenable: widget.controller!.videoPlayerController!,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10),
                                Container(
                                  height: 18,
                                  width: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    shape: BoxShape.rectangle,
                                    color: Colors.red,
                                  ),
                                  child: const Text(
                                    'Live',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  child: const Icon(
                                    Icons.picture_in_picture_alt_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onTap: () {
                                    widget.controller?.enablePictureInPicture(widget.betterPlayerKey);
                                  },
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onTap: () {

                                  },
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  child: Icon(
                                    widget.controller!.isFullScreen
                                        ? Icons.fullscreen_exit_rounded
                                        : Icons.fullscreen_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onTap: () => setState(() {
                                    if (widget.controller!.isFullScreen) {
                                      widget.controller!.exitFullScreen();
                                    } else {
                                      widget.controller!.enterFullScreen();
                                    }
                                  }),
                                ),
                                const SizedBox(width: 18),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
}
