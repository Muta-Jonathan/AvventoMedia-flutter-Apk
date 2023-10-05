import 'package:avvento_radio/componets/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ResizableImageWithOverlay extends StatelessWidget {
  final String imageUrl;
  final IconData? icon;
  final String text;

  const ResizableImageWithOverlay({
    super.key,
    required this.imageUrl,
    this.icon,
    required this.text,
  });

  Widget buildOverlay() {
    return   Positioned(
      bottom: 10,
      right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.black.withOpacity(0.4),
          child: icon == null
              ? Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          )
              : Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 8.0),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              icon != null ||  text.isNotEmpty ? buildOverlay(): Container()
            ],
          ),
        ),
      ),
    );
  }
}

