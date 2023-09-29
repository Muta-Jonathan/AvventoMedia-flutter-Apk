import 'package:avvento_radio/widgets/audio_players/controls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double widgetWidth = 0.88 * screenWidth;
    String publishedDate = Jiffy.parse(widget.spreakerEpisode.publishedAt).fromNow();
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: widgetWidth,
              height: screenWidth * 0.4,
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
                        width: screenWidth * 0.3,
                          height: screenWidth * 0.3,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
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
                    top: screenWidth * 0.05,
                    left: screenWidth * 0.35, // Adjust the left position as needed
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.45,
                          child: TextOverlay(
                            label: widget.spreakerEpisode.title,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextOverlay(
                          label: "Published $publishedDate",
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
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
