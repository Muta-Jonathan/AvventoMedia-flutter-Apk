import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../controller/library_controller.dart';
import '../../models/saved_item_model.dart';
import '../text/text_overlay_widget.dart';

class FavoriteButton extends StatelessWidget {
  final SavedItem item;
  const FavoriteButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();
    return Obx(() {
      final saved = library.isFavorite(item.id);
      return ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: GestureDetector(
          onTap: () {
            library.toggleFavorite(item);
          },
          child: Container(
            color: Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  saved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  size: 18,
                  color: saved ? Colors.redAccent : Theme.of(context).colorScheme.onSecondary,
                ),
                TextOverlay(
                  label: AppConstants.favorites,
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
