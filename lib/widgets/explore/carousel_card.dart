import 'package:flutter/material.dart';

import '../../models/exploremodels/programs.dart';
import '../images/resizable_image_widget.dart';
import '../text/text_overlay_widget.dart';

class CarouselCard extends StatelessWidget {
  final Programs explore;

  const CarouselCard({
    super.key,
    required this.explore
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ResizableImageWithOverlay(imageUrl: explore.urlToImage),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Text content
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                explore.showIcon ?
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSecondary,),
                        TextOverlay(label: explore.source.name, color: Theme.of(context).colorScheme.onSecondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ) : const SizedBox.shrink(),
                TextOverlay(label:  explore.title,color: Theme.of(context).colorScheme.onPrimary, fontSize: 15, fontWeight: FontWeight.bold, maxLines: 2,),
                TextOverlay(label: explore.description,color: Theme.of(context).colorScheme.onSecondary, maxLines: 2,),

              ],
            ),
          )
        ],
      ),
    );
  }
}
