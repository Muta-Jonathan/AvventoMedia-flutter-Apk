import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/widgets/audio_players/controls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/musicplayermodels/music_player_position.dart';
import '../../models/spreakermodels/spreaker_episodes.dart';
import '../text_overlay_widget.dart';

class AudioListDetailsWidget extends StatefulWidget {
  final SpreakerEpisode spreakerEpisode;
  const AudioListDetailsWidget({Key? key, required this.spreakerEpisode});

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioListDetailsWidget> {
  late AudioPlayer _audioPlayer;

  Stream<MusicPlayerPosition> get _musicPlayerPositionStream =>
      Rx.combineLatest3<Duration,Duration,Duration?, MusicPlayerPosition>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
          (position, bufferedPosition, duration) => MusicPlayerPosition(
              position, bufferedPosition, duration ?? Duration.zero)
      );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer()..setUrl(widget.spreakerEpisode.playbackUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.spreakerEpisode.imageUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 40.0, // Adjust the width to control the size
                          height: 40.0, // Adjust the height to control the size
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0, // Adjust the stroke width as needed
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary), // Change the color here
                            ),
                          ),),), // Placeholder widget
                      errorWidget: (context, _, error) => Icon(Icons.error,color: Theme.of(context).colorScheme.error,), // Error widget
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextOverlay(label: widget.spreakerEpisode.publishedAt, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      const SizedBox(height: 4.0,),
                      SizedBox(
                        child: TextOverlay(label: widget.spreakerEpisode.title, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 15.0,),
                        width: 170,
                      ),
                      const SizedBox(height: 4.0,),
                      Row(
                        children: [
                          Controls(audioPlayer: _audioPlayer),
                          SizedBox(
                            height: 30,
                            width: 80,
                            child: StreamBuilder<MusicPlayerPosition>(
                              stream: _musicPlayerPositionStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data;
                                final position = positionData?.position ?? Duration.zero;
                                final duration = positionData?.duration ?? Duration.zero;
                                final formattedPosition = Utils.formatDuration(position);
                                final formattedDuration = Utils.formatDuration(duration);

                                return Text(
                                  '$formattedPosition / $formattedDuration',
                                  style:const TextStyle(
                                    fontStyle: FontStyle.italic
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
