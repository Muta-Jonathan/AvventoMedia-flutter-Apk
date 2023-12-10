import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class CustomPlayerControlsWidget extends StatefulWidget {
  final BetterPlayerController? controller;
  final GlobalKey<BetterPlayerControlsState> betterPlayerKey;

  const CustomPlayerControlsWidget({
    Key? key,
    this.controller,
    required this.betterPlayerKey,
  }) : super(key: key);

  @override
  CustomPlayerControlsWidgetState createState() => CustomPlayerControlsWidgetState();
}

class CustomPlayerControlsWidgetState extends State<CustomPlayerControlsWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controlVisibility();
    // Listen to buffering updates
    widget.controller?.videoPlayerController!.addListener(_onBufferingUpdate);
  }

  void _onBufferingUpdate() {
    final isBuffering = widget.controller?.videoPlayerController!.value.isBuffering ?? false;
    if (isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }
  }

  void _showModal() {
    widget.betterPlayerKey.currentState?.onShowMoreClicked();
print("trying yup");
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
    _controlVisibility();
  }

void _controlVisibility() {
  if (widget.controller!.isPlaying()!) {
    widget.controller?.setControlsVisibility(true);
    Future.delayed(const Duration(seconds: 3), () {
      if (widget.controller!.isPlaying()!) {
        widget.controller?.setControlsVisibility(false);
      }
    });
  } else {
    widget.controller?.setControlsVisibility(true);
  }
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
    widget.controller?.videoPlayerController!.removeListener(_onBufferingUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: false,
        stream: widget.controller?.controlsVisibilityStream,
        builder: (context, snapshot) {
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
                  Visibility(
                    visible: _isBuffering,
                    child: const Center(
                      child: LoadingWidget(), // Show LoadingWidget if buffering
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
                                    _showModal();
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
