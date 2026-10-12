import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../controller/library_controller.dart';
import '../../models/saved_item_model.dart';
import '../text/text_overlay_widget.dart';
import 'save_bottom_sheet.dart';

/// A pill-shaped "+ Save" button that mirrors ShareButton in style.
/// Pass [item] fully constructed before calling this widget.
class SaveButton extends StatelessWidget {
  final SavedItem item;
  const SaveButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: GestureDetector(
        onTap: () => SaveBottomSheet.show(context, item),
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filled amber once it's in a playlist.
              Obx(() {
                final saved =
                    Get.find<LibraryController>().isInAnyPlaylist(item.id);
                return Icon(
                  saved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                  size: 18,
                  color: saved
                      ? const Color(0xFFFFB300)
                      : Theme.of(context).colorScheme.onSecondary,
                );
              }),
              TextOverlay(
                label: AppConstants.save,
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
