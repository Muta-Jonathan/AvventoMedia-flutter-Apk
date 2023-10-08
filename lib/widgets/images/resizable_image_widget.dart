import 'package:avvento_radio/componets/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ResizableImageWithOverlay extends StatelessWidget {
  final String imageUrl;

  const ResizableImageWithOverlay({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: SizedBox(
        width: Utils.calculateWidth(context, 0.90), // Constrain width to match parent
        height: Utils.calculateHeight(context, 0.25), // Constrain height to match parent
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, _, error) => Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

