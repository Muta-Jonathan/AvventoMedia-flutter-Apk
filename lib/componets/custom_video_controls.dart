import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPlayerControlsWidget extends StatefulWidget {
  final BetterPlayerController? controller;

  const CustomPlayerControlsWidget({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  _CustomPlayerControlsWidgetState createState() => _CustomPlayerControlsWidgetState();
}

class _CustomPlayerControlsWidgetState extends State<CustomPlayerControlsWidget> {
  void _onTap() {
    widget.controller?.setControlsVisibility(true);
    if (widget.controller!.isPlaying()!) {
      widget.controller?.pause();
    } else {
      widget.controller?.play();
    }
  }

  void _controlVisibility() {
    widget.controller?.setControlsVisibility(true);
    Future.delayed(const Duration(seconds: 3))
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _controlVisibility,
      child: StreamBuilder(
        initialData: false,
        stream: widget.controller?.controlsVisibilityStream,
        builder: (context, snapshot) {
          return Stack(
            children: [
              Visibility(
                visible: snapshot.data!,
                child: Positioned(
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _onTap,
                      backgroundColor: Colors.black.withOpacity(0.7),
                      child: widget.controller!.isPlaying()!
                          ? const Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 40,
                      )
                          : const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
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
                            Container(
                              height: 36,
                              width: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                shape: BoxShape.rectangle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Text(
                                '${_formatDuration(value.position)}/${_formatDuration(value.duration)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.picture_in_picture_alt_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              onTap: () {
                                // Add PiP functionality here
                                // For instance, invoke PiP using platform channels
                              },
                            ),
                            SizedBox(width: 15),
                            InkWell(
                              child: Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 24,
                              ),
                              onTap: () {
                                // Add settings functionality here
                                // For instance, open settings dialog
                              },
                            ),
                            SizedBox(width: 15),
                            InkWell(
                              child: Icon(
                                widget.controller!.isFullScreen
                                    ? Icons.fullscreen_exit_rounded
                                    : Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              onTap: () => setState(() {
                                if (widget.controller!.isFullScreen) {
                                  widget.controller!.exitFullScreen();
                                } else {
                                  widget.controller!.enterFullScreen();
                                }
                              }),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
