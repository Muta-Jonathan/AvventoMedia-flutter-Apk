import 'dart:async';

import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jiffy/jiffy.dart';

import '../../../controller/audio_player_controller.dart';
import '../../audio_players/audio_animation.dart';
import '../../text/text_overlay_widget.dart';

class EpisodeListDetailsWidget extends StatefulWidget {
  final PodcastEpisode episode;
  final AudioPlayerController audioPlayerController;
  const EpisodeListDetailsWidget({super.key, required this.episode, required this.audioPlayerController});

  @override
  EpisodePlayerWidgetState createState() => EpisodePlayerWidgetState();
}

class EpisodePlayerWidgetState extends State<EpisodeListDetailsWidget> {
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = widget.audioPlayerController.audioPlayer.playerStateStream.listen((_) {
      _updatePlayingState();
    });
  }

  void _updatePlayingState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String publishedDate = Jiffy.parse(Utils.formatTimestamp(timestamp: widget.episode.publishedAt, format: 'yyyy-MM-dd HH:mm:ss',)).fromNow();
    String? azuracastAPIKey = dotenv.env["AZURACAST_APIKEY"];

    bool isSelected = widget.audioPlayerController.currentMediaItem?.id == widget.episode.id;
    bool isPlayingAudio = isSelected && widget.audioPlayerController.audioPlayer.playing;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isSelected ? Colors.amber.withValues(alpha: 0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.episode.art,
                    httpHeaders: {
                      'Authorization': 'Bearer $azuracastAPIKey',
                    },
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(child: LoadingWidget()),
                    ),
                    errorWidget: (context, _, error) => Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
                if (isPlayingAudio)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: AudioIndicator(isPlaying: true),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextOverlay(
                    label: widget.episode.title,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.amber : Theme.of(context).colorScheme.onPrimary,
                    fontSize: 15,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  TextOverlay(
                    label: widget.episode.playlistMediaArtist,
                    fontSize: 13,
                    maxLines: 1,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  const SizedBox(height: 6),
                  TextOverlay(
                    label: "Published $publishedDate",
                    fontSize: 11,
                    maxLines: 1,
                    color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
            // Play icon indicator
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 4.0),
              child: Icon(
                isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                color: isSelected ? Colors.orange : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
