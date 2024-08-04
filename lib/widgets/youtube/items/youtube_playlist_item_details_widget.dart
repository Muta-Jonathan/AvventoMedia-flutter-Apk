import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Utils.calculateWidth(context,0.52),
                      child: TextOverlay(
                        label: widget.youTubePlaylistItemModel.title,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.042),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        (widget.youTubePlaylistItemModel.liveBroadcastContent == 'live' || widget.youTubePlaylistItemModel.liveBroadcastContent == 'upcoming') ?
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Container(
                            color: Colors.red,
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.dot_radiowaves_left_right,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 2.0),
                                TextOverlay(
                                  label: widget.youTubePlaylistItemModel.duration,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ) :
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
