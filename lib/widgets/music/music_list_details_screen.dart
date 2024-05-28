import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/spreakermodels/spreaker_episodes.dart';
import '../text/text_overlay_widget.dart';

class MusicListDetailsWidget extends StatefulWidget {
  final SpreakerEpisode spreakerEpisode;
  const MusicListDetailsWidget({super.key, required this.spreakerEpisode});

  @override
  MusicPlayerWidgetState createState() => MusicPlayerWidgetState();
}

class MusicPlayerWidgetState extends State<MusicListDetailsWidget> {

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
              child: Divider(),
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.spreakerEpisode.imageOriginalUrl,
                    fit: BoxFit.cover,
                    width: Utils.calculateWidth(context, 0.3),
                    height:  Utils.calculateHeight(context, 0.14),
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
                SizedBox(width:Utils.calculateWidth(context, 0.06),),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Utils.calculateHeight(context, 0.02)),
                    SizedBox(
                      width: Utils.calculateWidth(context,0.5),
                      child: TextOverlay(
                        label: widget.spreakerEpisode.title,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.042),
                      ),
                    ),
                    SizedBox(height: Utils.calculateHeight(context, 0.01)),
                    Row(
                      children: [
                        Icon(CupertinoIcons.folder_fill,color: Theme.of(context).colorScheme.onSecondaryContainer),
                        TextOverlay(
                          label: widget.spreakerEpisode.episodeId.toString(),
                          color: Theme.of(context).colorScheme.onPrimary,
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
