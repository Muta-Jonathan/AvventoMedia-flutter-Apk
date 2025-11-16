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

  @override
  void initState() {
    super.initState();
    widget.audioPlayerController.audioPlayer.playerStateStream.listen((_) {
      _updatePlayingState();
    });
  }

  void _updatePlayingState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String publishedDate = Jiffy.parse(Utils.formatTimestamp(timestamp: widget.episode.publishedAt, format: 'yyyy-MM-dd HH:mm:ss',)).fromNow();
    String? azuracastAPIKey = dotenv.env["AZURACAST_APIKEY"];

   return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 8.0,right: 8.0,top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.episode.art,
                      httpHeaders: {
                        'Authorization': 'Bearer $azuracastAPIKey',
                      },
                      fit: BoxFit.cover,
                      width: Utils.calculateWidth(context, 0.44),
                      height:  Utils.calculateHeight(context, 0.2),
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                            width:  Utils.calculateWidth(context, 0.3),
                            height:  Utils.calculateWidth(context, 0.3),
                            child: const LoadingWidget()
                        ),
                      ),
                      errorWidget: (context, _, error) => Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  widget.audioPlayerController.currentMediaItem?.id == widget.episode.id ? Positioned(
                    top: -25.0,
                    right: -18.0,
                    child:  AudioIndicator(isPlaying: widget.audioPlayerController.audioPlayer.playing,),
                  ) :  const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Utils.calculateWidth(context,0.44),
                    child: TextOverlay(
                      label: widget.episode.title,
                      fontWeight: FontWeight.bold,
                      color:  widget.audioPlayerController.currentMediaItem?.id == widget.episode.id ? Colors.amber : Theme.of(context).colorScheme.onPrimary,
                      fontSize: Utils.calculateWidth(context,0.042),
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: Utils.calculateWidth(context,0.44),
                    child: TextOverlay(
                      label: widget.episode.playlistMediaArtist,
                      fontSize: 14,
                      color: widget.audioPlayerController.currentMediaItem?.id == widget.episode.id ? Colors.amber : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  SizedBox(
                    width: Utils.calculateWidth(context,0.44),
                    child: TextOverlay(
                      label: "Published $publishedDate",
                      fontSize: 11,
                      maxLines: 1,
                      color: widget.audioPlayerController.currentMediaItem?.id == widget.episode.id ? Colors.amber : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
