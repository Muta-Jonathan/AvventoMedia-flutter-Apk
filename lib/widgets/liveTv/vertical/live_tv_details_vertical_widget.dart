import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/livetvmodel/livetv_model.dart';
import '../../text/text_overlay_widget.dart';

class LiveTvDetailsVerticalWidget extends StatefulWidget {
  final LiveTvModel liveTvModel;

  const LiveTvDetailsVerticalWidget({super.key, required this.liveTvModel});

  @override
  LiveTvDetailsVerticalWidgetState createState() => LiveTvDetailsVerticalWidgetState();
}

class LiveTvDetailsVerticalWidgetState extends State<LiveTvDetailsVerticalWidget> {

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
                    imageUrl:  widget.liveTvModel.imageUrl,
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
                        label: widget.liveTvModel.name,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Utils.calculateWidth(context,0.042),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.all(3.5),
                        child:
                        Row(
                          children: [
                            const Icon(CupertinoIcons.dot_radiowaves_left_right, color: Colors.white, size: 20,),
                            TextOverlay(
                              label: widget.liveTvModel.status,
                              fontSize: 12,
                              color: Colors.white,
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
