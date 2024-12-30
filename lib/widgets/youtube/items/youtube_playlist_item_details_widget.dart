import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../../../models/youtubemodels/youtube_playlist_item_model.dart';
import '../../images/resizable_image_widget_2.dart';
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
    final int views = int.tryParse(widget.youTubePlaylistItemModel.views) ?? 0;
    String view = Utils.formatViews(views);
    String publishedDate = Jiffy.parseFromDateTime(widget.youTubePlaylistItemModel.publishedAt).fromNow();

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
                (widget.youTubePlaylistItemModel.liveBroadcastContent == 'live' || widget.youTubePlaylistItemModel.liveBroadcastContent == 'upcoming') ?
                Expanded(
                  child: ResizableImageContainerWithOverlay(
                    imageUrl: widget.youTubePlaylistItemModel.thumbnailUrl,
                  ),
                ) :
                Expanded(
                  child: ResizableImageContainerWithOverlay(
                    imageUrl: widget.youTubePlaylistItemModel.thumbnailUrl,
                    text: widget.youTubePlaylistItemModel.duration,
                    textFontSize: 10,
                    overlayBottom: 0.2,
                    overlayRight: 3,
                    borderRadiusContainer: 10,
                    containerColor: Colors.black45,
                  ),
                ),
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Utils.calculateWidth(context,0.5),
                      child: TextOverlay(
                        label: widget.youTubePlaylistItemModel.title,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.041),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: Utils.calculateWidth(context,0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          (widget.youTubePlaylistItemModel.liveBroadcastContent == 'live' || widget.youTubePlaylistItemModel.liveBroadcastContent == 'upcoming') ?
                          const SizedBox.shrink() :
                          Row(
                            children: [
                              TextOverlay(
                                label: view,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                              TextOverlay(
                                label: "• $publishedDate",
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ]
                          ),
                        ],
                      ),
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
