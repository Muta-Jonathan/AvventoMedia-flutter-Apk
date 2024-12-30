import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

class ResizableImageContainerWithOverlay extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String? text;
  final double? textFontSize;
  final double? overlayBottom;
  final double? overlayRight;
  final Color? containerColor;
  final String? token;
  final double? borderRadius;
  final double? borderRadiusContainer;
  final String? svgPath;

  const ResizableImageContainerWithOverlay({
    super.key,
    this.imageUrl,
    this.icon,
    this.text,
    this.textFontSize = 14,
    this.overlayBottom = 10,
    this.overlayRight = 10,
    this.containerColor,
    this.token,
    this.borderRadius = 8,
    this.borderRadiusContainer = 8,
    this.svgPath
  });

  Widget buildOverlay() {
    return   Positioned(
      bottom: overlayBottom,
      right: overlayRight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadiusContainer!),
        child: SizedBox(
          height: 30,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              color: containerColor ?? Colors.red,
              child: icon != null
                  ? Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    text!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textFontSize,
                    ),
                  ),
                ],
              )
                  : svgPath != null
                  ? Row(
                children: [
                  SvgPicture.asset(
                    svgPath!,
                    color: Colors.white,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    text!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textFontSize!,
                    ),
                  ),
                ],
              )
                  : Text(
                text!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textFontSize!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget imageContainer() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      httpHeaders: token != null ? {
        'Authorization': 'Bearer $token',
      } : null ,
      fit: text != null || containerColor != null ? BoxFit.cover : BoxFit.fitWidth,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => const Center(
        child: SizedBox(
            width: 100,
            height: 100,
            child: LoadingWidget()
        ),
      ),
    errorWidget: (context, _, error) => Icon(
      Icons.error,
      color: Theme.of(context).colorScheme.error,
    ),
  );
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: SizedBox(
        width: Utils.calculateWidth(context, 0.76), // Constrain width to match parent
        height: Utils.calculateHeight(context, 0.1), // Constrain height to match parent
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              text != null || containerColor != null ? imageContainer() :
              InstaImageViewer(
                  backgroundColor:  Theme.of(context).colorScheme.surface,
                  child: imageContainer()
              ),
              icon != null || text != null || svgPath != null ? buildOverlay(): Container()
            ],
          ),
        ),
      ),
    );
  }
}

