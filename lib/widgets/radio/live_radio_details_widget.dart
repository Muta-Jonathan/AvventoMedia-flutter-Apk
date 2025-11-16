import 'package:avvento_media/models/radiomodel/radio_model.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/utils.dart';
import '../../routes/routes.dart';
import '../images/resizable_image_widget_2.dart';

class LiveRadioDetailsWidget extends StatefulWidget {
  final RadioModel radioModel;
  const LiveRadioDetailsWidget({super.key, required this.radioModel});

  @override
  State<LiveRadioDetailsWidget> createState() => _LiveRadioDetailsWidget();
}

class _LiveRadioDetailsWidget extends State<LiveRadioDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.getOnlineRadioRoute()),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ResizableImageContainerWithOverlay(
                imageUrl: widget.radioModel.imageUrl,
                text: widget.radioModel.status,
                textFontSize: 10,
                icon: Icons.music_note,)),
              const SizedBox(height: 15.0,),
              SizedBox(
                width: Utils.calculateWidth(context, 0.76),
                child:  TextOverlay(
                  label: widget.radioModel.name,
                  fontWeight: FontWeight.bold ,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 15.0,
                  maxLines: 1,),),
              const SizedBox(height: 8.0,),
            ],
        ),
      ),
    );
  }
}
