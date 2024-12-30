import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
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
          padding: const EdgeInsets.only(bottom: 10.0, left: 8.0,right: 8.0,top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.spreakerEpisode.imageOriginalUrl,
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
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Utils.calculateWidth(context,0.44),
                      child: TextOverlay(
                        label: widget.spreakerEpisode.title,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.042),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextOverlay(
                      label: "Published $publishedDate",
                      color: Theme.of(context).colorScheme.onPrimary,
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
