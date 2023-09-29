import 'package:avvento_radio/widgets/glass/frosted_glass_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
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
    // _audioPlayer = AudioPlayer()..setUrl(widget.spreakerEpisode.playbackUrl);
    _audioPlayer = AudioPlayer()..setAsset('assets/audio/music.mp3');
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
    String publishedDate = Jiffy.parse(selectedEpisode!.publishedAt).yMMMMEEEEdjm;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
                width: double.infinity,
                child: Marquee(
                  text: selectedEpisode!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  scrollAxis: Axis.horizontal,
                  blankSpace: screenWidth / 1.2,
                  velocity: 23.0, // Adjust the velocity to a lower value (e.g., 25.0)
                  pauseAfterRound: const Duration(seconds: 2),
                  startPadding: 0,
                  accelerationDuration: const Duration(seconds: 2),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
              Text(
                "Published on $publishedDate",
                style: const TextStyle(
                  fontSize:12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenHeight * 0.4,
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
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double parentHeight = constraints.maxHeight;
                      return  Stack(
                        children: [
                          // Cached Network Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              selectedEpisode.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Top Left Container with Stream Icon and Text
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: EdgeInsets.all(8),
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
                                    'ON AIR',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Container with Glass-like Background
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: FrostedGlassBox(
                              theWidth: double.infinity,
                              theHeight: parentHeight * 0.23,
                              theChild: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Implement the action for the download button
                                    },
                                    icon: Icon(CupertinoIcons.download_circle_fill, color: Colors.white),
                                  ),
                                  Controls(audioPlayer: _audioPlayer,),
                                  IconButton(
                                    onPressed: () {
                                      // Implement the action for the volume button
                                    },
                                    icon: Icon(CupertinoIcons.volume_up, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Progress Bar with Time
                          Positioned(
                            bottom: parentHeight * 0.17,
                            left: 0,
                            right: 0,
                            child: const Column(
                              children: [
                                Column(children: [
                                  LinearProgressIndicator(
                                    value: 0.6, // Adjust the playback progress value
                                    backgroundColor: Colors.grey,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5,left: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '0:30', // Current time
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          '2:00', // Total duration
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        )

    );
  }
}
