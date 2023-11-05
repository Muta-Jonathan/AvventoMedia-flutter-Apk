import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import '../componets/app_constants.dart';
import '../componets/utils.dart';
import '../controller/audio_player_controller.dart';
import '../models/musicplayermodels/music_player_position.dart';
import '../widgets/audio_players/controls.dart';
import '../widgets/providers/radio_station_provider.dart';
import '../widgets/text/text_overlay_widget.dart';

class OnlineRadioPage extends StatefulWidget {
  const OnlineRadioPage({super.key});

  @override
  State<OnlineRadioPage> createState() => _OnlineRadioPageState();

}

class _OnlineRadioPageState extends State<OnlineRadioPage> {
  // ignore: prefer_typing_uninitialized_variables
  late final radioStationProvider;
  late AudioPlayerController _audioPlayerController;
  MediaItem? currentMediaItem;
  StreamSubscription<MusicPlayerPosition>? _positionSubscription;
  bool isAudioSourceSet = false;

  double currentPosition = 0;
  double bufferedPosition = 0;
  double duration = 0;
  String title = "";
  String artist = "";

  final StreamController<MusicPlayerPosition> _musicPlayerPositionController = StreamController<MusicPlayerPosition>.broadcast();

  Stream<MusicPlayerPosition> get _musicPlayerPositionStream => _musicPlayerPositionController.stream;

  @override
  void initState() {
    super.initState();
    radioStationProvider = Provider.of<RadioStationProvider>(context, listen: false);
    _audioPlayerController = Get.find<AudioPlayerController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // React to changes in dependencies or fetch data here
    // Listen to the stream for MusicPlayerPosition updates
    final positionSubscription = _musicPlayerPositionStream.listen((position) {
      // Update the MediaItem whenever the position changes
      setState(() {
        currentMediaItem = position.mediaItem;
      });
    });

    // Cancel the subscription when the widget is disposed
    // This ensures that you clean up the subscription properly
    _positionSubscription?.cancel();
    _positionSubscription = positionSubscription;

    // Initialize or update other data as needed
    _init(radioStationProvider);
  }

  Future<void> _init(RadioStationProvider radioProvider) async {
    if (radioProvider.radioStation != null) {
      currentMediaItem = MediaItem(
        id: radioProvider.radioStation!.id.toString(),
        title: radioProvider.radioStation!.nowPlayingTitle,
        artist: radioProvider.radioStation!.artist,
        artUri: Uri.parse(radioProvider.radioStation!.imageUrl),
      );
      if (!isAudioSourceSet) {
        await _audioPlayerController.setAudioSource(
          radioProvider.radioStation!.streamUrl,
          currentMediaItem!,
        );
      }
      isAudioSourceSet = true;
    }
  }

  @override
  void dispose() {
    if (!_audioPlayerController.audioPlayer.playerState.playing) {
      _positionSubscription?.cancel();
      _audioPlayerController.dispose();
      _musicPlayerPositionController.close();
    }
     // stream_controller.close();
    super.dispose();
  }

  Duration? parseDuration(dynamic value) {
    if (value is int) {
      return Duration(seconds: value);
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _init(radioStationProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: Center(
            child: TextOverlay(
              label: AppConstants.nowPlaying,
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.share),
            onPressed: () {
              Utils.share("Take a look at AvventoRadio 💫 streaming now, \n ${AppConstants.webRadioUrl}");
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body:Consumer<RadioStationProvider> (
        builder: (context, radioProvider, child) {
          if (radioProvider.radioStation == null) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          } else {
            _init(radioProvider);
            return SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<MusicPlayerPosition>(
                    stream: _musicPlayerPositionStream,
                    builder: (_,snapshot) {
                      final positionData = snapshot.data;
                      final paddingWidth = Utils.calculateWidth(context, 0.05);
                      final paddingTop = Utils.calculateHeight(context, 0.06);
                      return Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.02),
                              child: Container(
                                width: screenWidth * 0.85,
                                height: screenHeight * 0.38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child:  Stack(
                                  children: [
                                    // Cached Network Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: radioProvider.radioStation!.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        placeholder: (context, url) => Center(
                                          child: SizedBox(
                                            width: 40.0, // Adjust the width to control the size
                                            height: 40.0, // Adjust the height to control the size
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3.0, // Adjust the stroke width as needed
                                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary), // Change the color here
                                            ),
                                          ),
                                        ), // Placeholder widget
                                        errorWidget: (context, _, error) => Icon(Icons.error,color: Theme.of(context).colorScheme.error,), // Error widget
                                      ),
                                    ),

                                    // Top Left Container with Stream Icon and Text
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [Colors.redAccent[100]!, Colors.red[500]!, Colors.red[900]!.withOpacity(0.9)],
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.antenna_radiowaves_left_right,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              AppConstants.onAIR,
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: paddingWidth , right: paddingWidth),
                                child: TextOverlay(label:  radioProvider.radioStation!.nowPlayingTitle, color: Theme.of(context).colorScheme.onPrimary,fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10,),
                              TextOverlay(label:  radioProvider.radioStation!.artist, color: Theme.of(context).colorScheme.onSecondary, fontSize: 14,),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: paddingWidth , right: paddingWidth, top: paddingTop),
                            child: ProgressBar(
                              baseBarColor: Colors.grey[600],
                              bufferedBarColor: Colors.grey,
                              thumbColor: Colors.redAccent,
                              thumbRadius: 5,
                              progressBarColor: Colors.redAccent,
                              progress: parseDuration(radioProvider.radioStation?.elapsed) ?? positionData?.position ?? Duration.zero,
                              total: parseDuration(radioProvider.radioStation?.duration) ?? Duration.zero,
                             ),
                          ),
                          const SizedBox(height: 20,),
                          Controls(audioPlayerController: _audioPlayerController,),
                          const SizedBox(height: 40,),
                          TextOverlay(label: AppConstants.avventoSlogan,color: Theme.of(context).colorScheme.onSecondaryContainer),
                          const SizedBox(height: 20,),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),

    );
  }
}
