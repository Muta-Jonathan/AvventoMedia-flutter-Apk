import 'package:avvento_radio/models/livetvmodel/liveTvModel.dart';
import 'package:avvento_radio/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../routes/routes.dart';
import '../images/resizable_image_widget_2.dart';

class LiveTvDetailsWidget extends StatefulWidget {
  final LiveTvModel liveTvModel;
  const LiveTvDetailsWidget({super.key, required this.liveTvModel});

  @override
  State<LiveTvDetailsWidget> createState() => _LiveTvDetailsWidget();
}

class _LiveTvDetailsWidget extends State<LiveTvDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.getLiveTvRoute()),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ResizableImageContainerWithOverlay(
                imageUrl: widget.liveTvModel.imageUrl,
                icon: CupertinoIcons.dot_radiowaves_left_right,
                text: widget.liveTvModel.status,
                ),
              ),
              const SizedBox(height: 15.0,),
              TextOverlay(label: widget.liveTvModel.name, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onPrimary, fontSize: 15.0,),
              const SizedBox(height: 8.0,),
            ],
        ),
      ),
    );
  }
}
