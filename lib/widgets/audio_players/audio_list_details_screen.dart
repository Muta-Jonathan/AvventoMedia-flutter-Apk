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
  const AudioListDetailsWidget({super.key, required this.spreakerEpisode});

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
    //_audioPlayer = AudioPlayer()..setAsset('assets/audio/music.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = 0.88 * screenWidth;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: widgetWidth,
            height: widgetWidth * 0.45,
            color: Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.spreakerEpisode.imageUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 40.0,
                          height: 40.0,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, _, error) => Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 120, // Adjust the left position as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextOverlay(
                        label: widget.spreakerEpisode.publishedAt,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 170,
                        child: TextOverlay(
                          label: widget.spreakerEpisode.title,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 15.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Controls(audioPlayer: _audioPlayer),
                          SizedBox(
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
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
