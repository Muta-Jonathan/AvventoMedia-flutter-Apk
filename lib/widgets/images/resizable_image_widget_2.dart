import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ResizableImageContainerWithOverlay extends StatelessWidget {
  final String imageUrl;
  final IconData? icon;
  final String? text;
  final Color? containerColor;
  final String? token;
  final double? borderRadius;

  const ResizableImageContainerWithOverlay({
    super.key,
    required this.imageUrl,
    this.icon,
    this.text,
    this.containerColor,
    this.token,
    this.borderRadius = 5
  });

  Widget buildOverlay() {
    return   Positioned(
      bottom: 10,
      right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: SizedBox(
          height: 30,
          child: Container(
            padding: const EdgeInsets.all(6),
            color: containerColor ?? Colors.red,
            child: icon == null
                ? Text(
              text!,
              style: const TextStyle(
                color: Colors.white,
              ),
            )
                : Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8.0),
                Text(
                  text!,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: SizedBox(
        width: Utils.calculateWidth(context, 0.80), // Constrain width to match parent
        height: Utils.calculateHeight(context, 0.1), // Constrain height to match parent
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                httpHeaders: token != null ? {
                  'Authorization': 'Bearer $token',
                } : null ,
                fit: BoxFit.cover,
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
              ),
              icon != null || text != null ? buildOverlay(): Container()
            ],
          ),
        ),
      ),
    );
  }
}

