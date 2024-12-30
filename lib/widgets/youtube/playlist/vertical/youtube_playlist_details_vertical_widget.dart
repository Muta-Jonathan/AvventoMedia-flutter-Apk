import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../text/text_overlay_widget.dart';

class YoutubePlaylistDetailsVerticalWidget extends StatefulWidget {
  final YoutubePlaylistModel youtubePlaylistModel;
  const YoutubePlaylistDetailsVerticalWidget({super.key, required this.youtubePlaylistModel});

  @override
  YoutubePlaylistDetailsVerticalWidgetState createState() => YoutubePlaylistDetailsVerticalWidgetState();
}

class YoutubePlaylistDetailsVerticalWidgetState extends State<YoutubePlaylistDetailsVerticalWidget> {

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
                    imageUrl: widget.youtubePlaylistModel.thumbnailUrl,
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
                        label: widget.youtubePlaylistModel.title,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.042),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        padding: const EdgeInsets.all(3.5),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icon/folder.svg',
                              color:  Theme.of(context).colorScheme.onSecondary,
                              width: 20,
                              height: 20,
                            ),
                            TextOverlay(
                              label: widget.youtubePlaylistModel.itemCount.toString(),
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ],
                        ),
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
