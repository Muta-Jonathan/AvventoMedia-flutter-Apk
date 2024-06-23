import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../models/youtubemodels/youtube_playlist_model.dart';
import '../../images/resizable_image_widget_2.dart';

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
      padding: const EdgeInsets.only(top: 15,bottom: 15,left: 15,right: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ResizableImageContainerWithOverlay(
              imageUrl: widget.youtubePlaylistModel.thumbnailUrl,
              icon: CupertinoIcons.folder_solid,
              text: widget.youtubePlaylistModel.itemCount.toString(),
              containerColor: Colors.black54.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 15.0,),
          TextOverlay(label: widget.youtubePlaylistModel.title, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onPrimary, fontSize: 15.0,),
          const SizedBox(height: 8.0,),
        ],
      ),
    );
  }
}
