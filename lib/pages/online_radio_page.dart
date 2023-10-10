import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart' as R;

import '../componets/app_constants.dart';
import '../componets/utils.dart';
import '../models/musicplayermodels/music_player_position.dart';
import '../widgets/audio_players/controls.dart';
import '../widgets/providers/radio_station_provider.dart';
import '../widgets/text/text_overlay_widget.dart';

class OnlineRadioPage extends StatefulWidget {
  @override
  State<OnlineRadioPage> createState() => _OnlineRadioPageState();

}

class _OnlineRadioPageState extends State<OnlineRadioPage> {
  late AudioPlayer _audioPlayer;

  Stream<MusicPlayerPosition> get _musicPlayerPositionStream =>
      R.Rx.combineLatest3<Duration,Duration,Duration?, MusicPlayerPosition>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
              (position, bufferedPosition, duration) => MusicPlayerPosition(
              position, bufferedPosition, duration ?? Duration.zero)
      );
  @override
  void initState() {
    super.initState();
    Provider.of<RadioStationProvider>(context, listen: false).fetchRadioStation();

  }

  @override
  Widget build(BuildContext context) {
    final radioStationProvider = Provider.of<RadioStationProvider>(context);
    _audioPlayer = AudioPlayer()..setUrl( radioStationProvider.radioStation!.streamUrl);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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

            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Consumer<RadioStationProvider>(
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
            return SingleChildScrollView(
              child: Column(
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
                                  ),), // Placeholder widget
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
                  StreamBuilder<MusicPlayerPosition>(
                    stream: _musicPlayerPositionStream,
                    builder: (_,snapshot) {
                      final positionData = snapshot.data;
                      final paddingWidth = Utils.calculateWidth(context, 0.05);
                      final paddingTop = Utils.calculateHeight(context, 0.06);
                      return Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: paddingWidth , right: paddingWidth),
                                child: TextOverlay(label:  radioProvider.radioStation!.nowPlayingTitle, color: Theme.of(context).colorScheme.onPrimary,fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10,),
                              TextOverlay(label:  radioProvider.radioStation!.artist, color: Theme.of(context).colorScheme.onPrimary,),
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
                              progress: positionData?.position ?? Duration.zero,
                              buffered:  positionData?.bufferedPosition ?? Duration.zero,
                              total: positionData?.duration ?? Duration.zero,
                              onSeek: _audioPlayer.seek,),
                          ),
                          const SizedBox(height: 20,),
                          Controls(audioPlayer: _audioPlayer),
                          const SizedBox(height: 60,),
                          TextOverlay(label: AppConstants.avventoSlogan,color: Theme.of(context).colorScheme.onSecondaryContainer)
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
