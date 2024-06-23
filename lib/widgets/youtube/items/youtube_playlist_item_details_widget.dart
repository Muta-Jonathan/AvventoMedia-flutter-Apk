import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/youtubemodels/youtube_playlist_item_model.dart';
import '../../text/text_overlay_widget.dart';

class YoutubePlaylistItemDetailsWidget extends StatefulWidget {
  final YouTubePlaylistItemModel youTubePlaylistItemModel;
  const YoutubePlaylistItemDetailsWidget({super.key, required this.youTubePlaylistItemModel});

  @override
  YoutubePlaylistItemDetailsWidgetState createState() => YoutubePlaylistItemDetailsWidgetState();
}

class YoutubePlaylistItemDetailsWidgetState extends State<YoutubePlaylistItemDetailsWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: AppConstants.leftMain,right: 8.0,top: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child:Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: AppConstants.rightMain),
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.youTubePlaylistItemModel.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: Utils.calculateWidth(context, 0.36),
                    height:  Utils.calculateHeight(context, 0.094),
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                          width:  Utils.calculateWidth(context, 0.1),
                          height:  Utils.calculateWidth(context, 0.1),
                          child: const LoadingWidget()
                      ),
                    ),
                    errorWidget: (context, _, error) => Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 6,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Utils.calculateWidth(context,0.52),
                      child: TextOverlay(
                        label: widget.youTubePlaylistItemModel.title,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.042),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        TextOverlay(
                          label: widget.youTubePlaylistItemModel.duration,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
