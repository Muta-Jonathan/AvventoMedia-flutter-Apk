import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/widgets/audio_players/controls.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/musicplayermodels/music_player_position.dart';

class AudioListDetailsWidget extends StatefulWidget {
  const AudioListDetailsWidget({super.key});

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
    _audioPlayer = AudioPlayer()..setAsset('assets/audio/music.mp3');
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
              color: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://avventohome.org/wp-content/uploads/2023/04/landscapeRadio-11.png',
                      width: 160,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Audio Title", style: TextStyle(fontSize: 18.0)),
                      const Text("Artist Name", style: TextStyle(fontSize: 16.0)),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Controls(audioPlayer: _audioPlayer),
                          SizedBox(
                            height: 30,
                            width: 60,
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
                                  style:TextStyle(
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
