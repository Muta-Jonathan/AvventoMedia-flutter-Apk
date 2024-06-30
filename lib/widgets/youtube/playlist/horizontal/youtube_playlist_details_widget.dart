import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';

import '../../../../componets/utils.dart';
import '../../../../models/youtubemodels/youtube_playlist_model.dart';
import '../../../images/resizable_image_widget_2.dart';

class YoutubePlaylistDetailsWidget extends StatefulWidget {
  final YoutubePlaylistModel youtubePlaylistModel;
  const YoutubePlaylistDetailsWidget({super.key, required this.youtubePlaylistModel});

  @override
  State<YoutubePlaylistDetailsWidget> createState() => _YoutubePlaylistDetailsWidget();
}

class _YoutubePlaylistDetailsWidget extends State<YoutubePlaylistDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ResizableImageContainerWithOverlay(
              imageUrl: widget.youtubePlaylistModel.thumbnailUrl,
              svgPath: 'assets/icon/folder.svg',
              text: widget.youtubePlaylistModel.itemCount.toString(),
              containerColor: Colors.black38,
            ),
          ),
          const SizedBox(height: 15.0,),
          SizedBox(
              width: Utils.calculateWidth(context, 0.76),
              child: TextOverlay(label: widget.youtubePlaylistModel.title, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onPrimary, fontSize: 15.0,)),
          const SizedBox(height: 8.0,),
        ],
      ),
    );
  }
}
