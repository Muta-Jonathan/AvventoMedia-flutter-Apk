import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/models/exploremodels/programs.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:avvento_media/widgets/icons/boxed_icon_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HomeExploreDetailsScreen extends StatefulWidget {
  final Programs explore;
  const HomeExploreDetailsScreen({super.key, required this.explore});

  @override
  State<HomeExploreDetailsScreen> createState() => _HomeExploreDetailsScreenState();
}

class _HomeExploreDetailsScreenState extends State<HomeExploreDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = 0.85 * screenWidth; // 80% of the screen width
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0), // Rounded corners with radius 15.0
      child: Container(
        width: widgetWidth,
        height: Utils.calculateHeight(context, 1) , // 16:9 aspect ratio based on the width
        margin: const EdgeInsets.all(5.0),
        child: Stack(
          children: [
            // Add your GIF or photo
            CachedNetworkImage(
              imageUrl: widget.explore.urlToImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => const Center(
                  child: SizedBox(
                      width: 40.0, // Adjust the width to control the size
                      height: 40.0, // Adjust the height to control the size
                      child: LoadingWidget()
                  ),), // Placeholder widget
              errorWidget: (context, _, error) => Icon(Icons.error,color: Theme.of(context).colorScheme.error,), // Error widget
            ),
            // Gradient Decoration in front of the image
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.onSurface, Colors.transparent], // Black gradient from bottom
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            // Icon Widget
            widget.explore.showIcon ? const Positioned(
              top: 10.0,
              right: 10.0,
              child: BoxedIcon(backgroundColor: Colors.white), // Use the separate Icon Widget
            ) :  const SizedBox.shrink(),
            // Texts at the bottom
            Positioned(
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextOverlay(label: widget.explore.source.name, color: Theme.of(context).colorScheme.onSecondaryContainer),
                  const SizedBox(height: 4.0,),
                  TextOverlay(label: widget.explore.title, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 15.0,),
                  const SizedBox(height: 4.0,),
                  TextOverlay(label: widget.explore.description, color: Theme.of(context).colorScheme.onSecondaryContainer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
