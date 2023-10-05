import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/widgets/text/text_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as R;

import '../controller/episode_controller.dart';
import '../models/musicplayermodels/music_player_position.dart';
import '../widgets/audio_players/controls.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({Key? key}) : super(key: key);

  @override
  PodcastPageState createState() => PodcastPageState();
}

class PodcastPageState extends State<PodcastPage> {
  final EpisodeController episodeController = Get.find();
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
    _audioPlayer = AudioPlayer()..setUrl( episodeController.selectedEpisode.value!.playbackUrl);
    // _audioPlayer = AudioPlayer()..setAsset('assets/audio/music.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEpisode = episodeController.selectedEpisode.value;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //String publishedDate = Jiffy.parse(selectedEpisode!.publishedAt).yMMMMEEEEdjm;
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

              },
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        body: SingleChildScrollView(
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
                                imageUrl: selectedEpisode!.imageUrl,
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
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.antenna_radiowaves_left_right,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                        selectedEpisode.type,
                                      style: const TextStyle(color: Colors.white),
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
                            child: TextOverlay(label:  selectedEpisode.title, color: Theme.of(context).colorScheme.onPrimary,fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10,),
                          TextOverlay(label:  selectedEpisode.type, color: Theme.of(context).colorScheme.onPrimary,),
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
        )

    );
  }
}