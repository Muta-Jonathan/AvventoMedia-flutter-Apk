import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/utils.dart';
import '../../models/highlightmodel/highlight_model.dart';
import '../images/resizable_image_widget_2.dart';

class HightlightsDetailsWidget extends StatefulWidget {
  final HighlightModel highlightModel;
  const HightlightsDetailsWidget({super.key, required this.highlightModel,});

  @override
  State<HightlightsDetailsWidget> createState() => _HightlightsDetailsWidget();
}

class _HightlightsDetailsWidget extends State<HightlightsDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    final model =  widget.highlightModel;
    final youtubeItem =  widget.highlightModel.youtubePlaylistItem;
    final youtubePlaylist =  widget.highlightModel.youtubePlaylist;

    // Determine imageUrl
    String? imageUrl;
    if (youtubeItem != null) {
      imageUrl = youtubeItem.thumbnailUrl;
    } else if (youtubePlaylist != null) {
      imageUrl = youtubePlaylist.thumbnailUrl;
    } else {
      imageUrl = model.imageUrl;
    }

    // Determine title
    String? name;
    if (youtubeItem != null) {
      name = youtubeItem.title;
    } else if (youtubePlaylist != null) {
      name = youtubePlaylist.title;
    } else {
      name = model.name;
    }

    // Determine text
    String? text;
   if (youtubePlaylist != null) {
      text = youtubePlaylist.itemCount.toString();
    } else {
      text = null;
    }

    // Determine containerColor
    Color? containerColor;
    if (youtubeItem != null) {
      if (youtubeItem.liveBroadcastContent == 'live' || youtubeItem.liveBroadcastContent == 'upcoming') {
        containerColor = Colors.red;
      } else {
        containerColor = Colors.black38;
      }
    } else if (youtubePlaylist != null) {
      containerColor = Colors.black38; // Adjust logic as needed
    } else {
      containerColor = null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10,left: 10,right: 5),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height:  Utils.calculateAspectHeight(context, 0.92),
              width:  Utils.calculateAspectHeight(context, 1.61),
              child: ResizableImageContainerWithOverlay(
                imageUrl: imageUrl,
                text: text,
                containerColor: containerColor,
                svgPath: youtubePlaylist != null ? 'assets/icon/folder.svg' : null,
                icon: (youtubeItem?.liveBroadcastContent == 'live' || youtubeItem?.liveBroadcastContent == 'upcoming') ? CupertinoIcons.dot_radiowaves_left_right : null,
              ),
            ),
            const SizedBox(height: 10.0,),
            SizedBox(
                width: Utils.calculateWidth(context, 0.8),
                child: TextOverlay(label: model.title, color: Colors.amber,allCaps: true, maxLines: 1,)),
            const SizedBox(height: 2.0,),
            SizedBox(
                width: Utils.calculateWidth(context, 0.8),
                child: TextOverlay(label: name, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0,maxLines: 2,)),
          ],
      ),
    );
  }
}
