import 'package:avvento_media/componets/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/spreakermodels/spreaker_episodes.dart';
import '../text/text_overlay_widget.dart';

class AudioListDetailsWidget extends StatefulWidget {
  final SpreakerEpisode spreakerEpisode;
  const AudioListDetailsWidget({super.key, required this.spreakerEpisode});

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioListDetailsWidget> {

  @override
  Widget build(BuildContext context) {
    String publishedDate = Jiffy.parse(widget.spreakerEpisode.publishedAt).fromNow();
    return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18.0, left: 18.0,right: 18.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: Utils.calculateWidth(context, 0.88),
              height:  Utils.calculateWidth(context, 0.4),
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
                        imageUrl: widget.spreakerEpisode.imageOriginalUrl,
                        fit: BoxFit.cover,
                        width: Utils.calculateWidth(context, 0.3),
                          height:  Utils.calculateWidth(context, 0.3),
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width:  Utils.calculateWidth(context, 0.3),
                            height:  Utils.calculateWidth(context, 0.3),
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
                    top: Utils.calculateWidth(context,0.05),
                    left: Utils.calculateWidth(context,0.35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Utils.calculateWidth(context,0.45),
                          child: TextOverlay(
                            label: widget.spreakerEpisode.title,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: Utils.calculateWidth(context,0.05),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextOverlay(
                          label: "Published $publishedDate",
                          color: Theme.of(context).colorScheme.onPrimary,
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
