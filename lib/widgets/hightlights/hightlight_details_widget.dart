import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';

import '../../models/highlightmodel/highlight_model.dart';
import '../images/resizable_image_widget.dart';

class HightlightsDetailsWidget extends StatefulWidget {
  final HighlightModel highlightModel;
  const HightlightsDetailsWidget({super.key, required this.highlightModel,});

  @override
  State<HightlightsDetailsWidget> createState() => _HightlightsDetailsWidget();
}

class _HightlightsDetailsWidget extends State<HightlightsDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10,left: 10,right: 5),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResizableImageWithOverlay(imageUrl: widget.highlightModel.imageUrl),
            const SizedBox(height: 10.0,),
            TextOverlay(label: widget.highlightModel.title, color: Colors.orange,allCaps: true),
            const SizedBox(height: 5.0,),
            TextOverlay(label: widget.highlightModel.name, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onPrimary, fontSize: 15.0,),
          ],
      ),
    );
  }
}
