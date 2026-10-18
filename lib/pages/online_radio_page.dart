import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import '../components/app_constants.dart';
import '../components/utils.dart';
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

  String? _nextProgram;

  final StreamController<MusicPlayerPosition> _musicPlayerPositionController = StreamController<MusicPlayerPosition>.broadcast();

  Stream<MusicPlayerPosition> get _musicPlayerPositionStream => _musicPlayerPositionController.stream;

  @override
  void initState() {
    super.initState();
    radioStationProvider = Provider.of<RadioStationProvider>(context, listen: false);
    _audioPlayerController = Get.find<AudioPlayerController>();
    // Defer reactive updates to after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioPlayerController.isLive.value = true;
    });
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

    // The Consumer in build() handles initializing the radio station provider.
  }

  Future<void> _init(RadioStationProvider radioProvider) async {
    if (radioProvider.radioStation != null) {
      currentMediaItem = MediaItem(
        id: radioProvider.radioStation!.id.toString(),
        title: radioProvider.radioStation!.nowPlayingTitle,
        artist: radioProvider.radioStation!.artist,
        artUri: Uri.parse(radioProvider.radioStation!.imageUrl),
        duration: Utils.parseDuration(radioProvider.radioStation!.duration),
      );

      // Update _nextProgram ONLY IF new data is not empty
      if (radioProvider.radioStation!.nextProgram.isNotEmpty) {
        _nextProgram = radioProvider.radioStation!.nextProgram;
      }

      if (!_audioPlayerController.audioPlayer.playerState.playing) {
        await _audioPlayerController.setAudioSource(
          radioProvider.radioStation!.streamUrl,
          currentMediaItem!,
        );
      } else {
        // Dynamically update the notification if the radio is already playing
        _audioPlayerController.updateRadioProgram(
          radioProvider.radioStation!.nowPlayingTitle,
          radioProvider.radioStation!.artist,
          radioProvider.radioStation!.imageUrl,
          Utils.parseDuration(radioProvider.radioStation!.duration),
          Utils.parseDuration(radioProvider.radioStation!.elapsed),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!_audioPlayerController.audioPlayer.playerState.playing) {
      _positionSubscription?.cancel();
      _audioPlayerController.dispose();
      _musicPlayerPositionController.close();
    }
    super.dispose();
  }


  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: SizedBox(
          height: AppConstants.height30,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextOverlay(
                  label: AppConstants.nowPlaying,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: AppConstants.fontSize18,
                ),
                const SizedBox(width: 8), // space between text and dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.share,color: Theme.of(context).colorScheme.onPrimary,),
            onPressed: () {
              Utils.share("${AppConstants.shareStream}, \n ${AppConstants.webRadioUrl}");
            },
          ),
        ],
        backgroundColor:   Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body:Consumer<RadioStationProvider> (
        builder: (context, radioProvider, child) {
          if (radioProvider.radioStation == null) {
            return const LoadingWidget();
          } else {
            if (!_isInitialized) {
              _isInitialized = true;
              _init(radioProvider);
            } else {
              // Dynamically update the metadata on every tick
              _audioPlayerController.updateRadioProgram(
                radioProvider.radioStation!.nowPlayingTitle,
                radioProvider.radioStation!.artist,
                radioProvider.radioStation!.imageUrl,
                Utils.parseDuration(radioProvider.radioStation!.duration),
                Utils.parseDuration(radioProvider.radioStation!.elapsed),
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<MusicPlayerPosition>(
                    stream: _musicPlayerPositionStream,
                    builder: (_,snapshot) {
                      final paddingWidth = Utils.calculateWidth(context, 0.05);
                      final paddingTop = Utils.calculateHeight(context, 0.02);
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: radioProvider.radioStation!.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (context, url) => const Center(
                                      child: SizedBox(
                                        width: AppConstants.width40, // Adjust the width to control the size
                                        height: AppConstants.height40, // Adjust the height to control the size
                                        child: LoadingWidget()
                                      ),
                                    ), // Placeholder widget
                                    errorWidget: (context, _, error) => Icon(Icons.error,color: Theme.of(context).colorScheme.error,), // Error widget
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Utils.calculateHeight(context, 0.03)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: paddingWidth , right: paddingWidth),
                                child: TextOverlay(label:  radioProvider.radioStation!.nowPlayingTitle, color: Theme.of(context).colorScheme.onPrimary,fontSize: AppConstants.fontSize20, fontWeight: FontWeight.bold, textAlign: TextAlign.center,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextOverlay(label:  radioProvider.radioStation!.artist, color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, textAlign: TextAlign.center,),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: paddingWidth , right: paddingWidth, top: paddingTop),
                            child: IgnorePointer(
                              child: ProgressBar(
                                baseBarColor: Colors.grey[600],
                                bufferedBarColor: Colors.grey,
                                thumbColor: Colors.transparent,
                                thumbGlowRadius: 0,
                                thumbRadius: 0,
                                buffered: Utils.parseDuration(radioProvider.radioStation?.elapsed),
                                progressBarColor: Colors.redAccent,
                                progress: Utils.parseDuration(radioProvider.radioStation?.elapsed),
                                timeLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                total: Utils.parseDuration(radioProvider.radioStation?.duration),
                               ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextOverlay(label: _nextProgram ?? "", color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, textAlign: TextAlign.center,),
                          ),
                          SizedBox(height: Utils.calculateHeight(context, 0.01)),
                          Controls(audioPlayerController: _audioPlayerController,),
                          SizedBox(height: Utils.calculateHeight(context, 0.08)),
                          TextOverlay(label: AppConstants.avventoSlogan,color: Theme.of(context).colorScheme.onSecondaryContainer),
                          SizedBox(height: Utils.calculateHeight(context, 0.02)),
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
