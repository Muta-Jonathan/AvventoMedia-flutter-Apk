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
  final double widthMultiplier;

  const ResizableImageContainerWithOverlay({
    super.key,
    this.imageUrl,
    this.icon,
    this.text,
    this.textFontSize = 14,
    this.overlayBottom = 6,
    this.overlayRight = 8,
    this.containerColor,
    this.token,
    this.borderRadius = 8,
    this.borderRadiusContainer = 8,
    this.svgPath,
    this.widthMultiplier = 0.76,
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
              padding: const EdgeInsets.all(2.8),
              color: containerColor ?? Colors.red,
              child: icon != null
                  ? Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  if (text != null) ...[
                    const SizedBox(width: 4.0),
                    Text(
                      text!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: textFontSize,
                      ),
                    ),
                  ],
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
                  if (text != null) ...[
                    const SizedBox(width: 8.0),
                    Text(
                      text!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textFontSize!,
                      ),
                    ),
                  ],
                ],
              )
                  : text != null ? Text(
                text!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textFontSize!,
                ),
              ) : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget imageContainer(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Icon(Icons.image_not_supported, color: Theme.of(context).colorScheme.onSurface),
      );
    }
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
      errorWidget: (context, url, error) {
        if (url.contains('maxresdefault')) {
          return CachedNetworkImage(
            imageUrl: url.replaceAll('maxresdefault', 'hqdefault'),
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
            errorWidget: (context, url, error) => Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: SizedBox(
        width: Utils.calculateResponsiveWidth(context, widthMultiplier), // Constrain width to match parent
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              text != null || containerColor != null ? imageContainer(context) :
              InstaImageViewer(
                  backgroundColor:  Theme.of(context).colorScheme.surface,
                  child: imageContainer(context)
              ),
              icon != null || text != null || svgPath != null ? buildOverlay(): Container()
            ],
          ),
        ),
      ),
    );
  }
}

