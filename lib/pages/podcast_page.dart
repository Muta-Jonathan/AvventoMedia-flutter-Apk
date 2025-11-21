import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart' as r_x;

import '../controller/audio_player_controller.dart';
import '../controller/podcast_episode_controller.dart';
import '../models/musicplayermodels/music_player_position.dart';
import '../widgets/audio_players/controls.dart';
import '../widgets/audio_players/speed_control.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key});

  @override
  PodcastPageState createState() => PodcastPageState();
}

class PodcastPageState extends State<PodcastPage> {
  final PodcastEpisodeController episodeController = Get.find();
  late AudioPlayerController _audioPlayerController;
  final StreamController<MusicPlayerPosition> _musicPlayerPositionController = StreamController<MusicPlayerPosition>.broadcast();

  //Stream<MusicPlayerPosition> get _musicPlayerPositionStream => _musicPlayerPositionController.stream;
  Stream<MusicPlayerPosition> get _musicPlayerPositionStream =>
      r_x.Rx.combineLatest3<Duration,Duration,Duration?, MusicPlayerPosition>(
          _audioPlayerController.audioPlayer.positionStream,
          _audioPlayerController.audioPlayer.bufferedPositionStream,
          _audioPlayerController.audioPlayer.durationStream,
              (position, bufferedPosition, duration) => MusicPlayerPosition(
              position, bufferedPosition, duration ?? Duration.zero,  _audioPlayerController.currentMediaItem!)
      );

  @override
  void initState() {
    super.initState();
    _audioPlayerController = Get.find<AudioPlayerController>();
    // Check if the selected episode is different from the current media item
    final selectedEpisode = episodeController.selectedEpisode.value!;
    // Check if the selected episode is different from the current media item
    // var currentMediaItem = _audioPlayerController.currentMediaItem.value;

    if (_audioPlayerController.currentMediaItem == null || _audioPlayerController.currentMediaItem!.id != selectedEpisode.id) {
      _audioPlayerController.currentMediaItem = MediaItem(
        id: selectedEpisode.id,
        title: selectedEpisode.title,
        artist: selectedEpisode.playlistMediaArtist,
        artUri: Uri.parse(selectedEpisode.art),
      );
      _audioPlayerController.setAudioSource(
          selectedEpisode.downloadLink,
          _audioPlayerController.currentMediaItem!);
      }
    }

  @override
  void dispose() {
    if (!_audioPlayerController.audioPlayer.playerState.playing) {
      _musicPlayerPositionStream.drain(); // Dispose of the stream
      _audioPlayerController.dispose();
      _musicPlayerPositionController.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final selectedEpisode = episodeController.selectedEpisode.value;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String publishedDate = Jiffy.parse(Utils.formatTimestamp(timestamp: selectedEpisode!.publishedAt, format: 'yyyy-MM-dd HH:mm:ss',)).fromNow();

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: SizedBox(
            height: 30,
            child: Center(
              child: TextOverlay(
                label: AppConstants.podcasts,
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.share,),
              onPressed: () async {
                Utils.share("Come Join Me, Listen to the wonderful Podcast on AvventoMedia 💫, \n ${selectedEpisode.publicLink}");
              },
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.surface,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
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
                                imageUrl: selectedEpisode.art,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                      width: AppConstants.width40, // Adjust the width to control the size
                                      height: AppConstants.height40, // Adjust the height to control the size
                                      child: LoadingWidget()
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
                                    SvgPicture.asset(
                                      'assets/icon/podcast.svg',
                                      color: Colors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      selectedEpisode.playlistMediaAlbum,
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
                  SizedBox(height: Utils.calculateHeight(context, 0.03)),
                  StreamBuilder<MusicPlayerPosition>(
                    stream: _musicPlayerPositionStream,
                    builder: (_,snapshot) {
                      final positionData = snapshot.data;
                      final paddingWidth = Utils.calculateWidth(context, 0.05);
                      final paddingTop = Utils.calculateHeight(context, 0.02);
                      return Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: paddingWidth , right: paddingWidth),
                                child: TextOverlay(label: _audioPlayerController.currentMediaItem!.title, color: Theme.of(context).colorScheme.onPrimary,fontSize: AppConstants.fontSize20, fontWeight: FontWeight.bold, textAlign: TextAlign.center,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextOverlay(label:  _audioPlayerController.currentMediaItem?.artist ?? '', color: Theme.of(context).colorScheme.onSecondaryContainer,fontSize: 16, textAlign: TextAlign.center,),
                              ),
                              TextOverlay(label: "Published $publishedDate",color: Theme.of(context).colorScheme.onSecondaryContainer, textAlign: TextAlign.center,)
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
                              timeLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                              onSeek: _audioPlayerController.audioPlayer.seek,),
                          ),
                          SizedBox(height: Utils.calculateHeight(context, 0.02)),
                          Controls(audioPlayerController: _audioPlayerController,),
                          SizedBox(height: Utils.calculateHeight(context, 0.08),),
                          TextOverlay(label: AppConstants.avventoSlogan,color: Theme.of(context).colorScheme.onSecondaryContainer),
                          SizedBox(height: Utils.calculateHeight(context, 0.02),),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [SpeedControl(audioPlayerController: _audioPlayerController,),
                ],
              ),
            ),
          ],
        )
    );
  }
}
