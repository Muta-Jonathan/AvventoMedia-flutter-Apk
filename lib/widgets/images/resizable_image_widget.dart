import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
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
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
        width: Utils.calculateWidth(context, 0.9), // Constrain width to match parent
        height: Utils.calculateHeight(context, 0.24), // Constrain height to match parent
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
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
            ],
          ),
        ),
      ),
    );
  }
}

