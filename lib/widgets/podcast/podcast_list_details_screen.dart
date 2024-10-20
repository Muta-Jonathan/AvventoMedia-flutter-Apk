import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

import '../text/text_overlay_widget.dart';

class PodcastListDetailsWidget extends StatefulWidget {
  final RadioPodcast radioPodcast;
  const PodcastListDetailsWidget({super.key, required this.radioPodcast});

  @override
  PodcastPlayerWidgetState createState() => PodcastPlayerWidgetState();
}

class PodcastPlayerWidgetState extends State<PodcastListDetailsWidget> {
  static String? azuracastAPIKey = dotenv.env["AZURACAST_APIKEY"];

  @override
  Widget build(BuildContext context) {
   return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 8.0,right: 8.0,top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child:SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.radioPodcast.art,
                    httpHeaders:  {
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
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Utils.calculateWidth(context,0.44),
                      child: TextOverlay(
                        label: widget.radioPodcast.title,
                        maxLines: 1,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.042),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icon/folder.svg',
                          color:  Theme.of(context).colorScheme.onSecondaryContainer,
                          width: 20,
                          height: 20,
                        ),
                        TextOverlay(
                          label: '${widget.radioPodcast.episodes.toString()} Episodes',
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    )
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
