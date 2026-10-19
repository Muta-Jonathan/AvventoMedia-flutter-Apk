import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../components/app_snackbar.dart';
import '../../controller/library_controller.dart';
import '../../themes/avvento_colors.dart';

class NewPlaylistBottomSheet {
  /// [confirm]: show "Playlist created". Callers that follow up with their
  /// own message (e.g. "Saved to …") pass false.
  static Future<String?> show(BuildContext context, {bool confirm = true}) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      // Draws its own handle; tokens suit both themes.
      showDragHandle: false,
      backgroundColor: Theme.of(context).avvento.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final c = Theme.of(ctx).avvento;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: c.line,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.newPlaylist,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: c.text),
                  decoration: InputDecoration(
                    hintText: AppConstants.playlistNameHint,
                    hintStyle: TextStyle(
                        color: c.text3),
                    filled: true,
                    fillColor: c.surface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? AppConstants.playlistNameEmpty
                          : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.accent,
                      foregroundColor: c.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final library = Get.find<LibraryController>();
                        final meta = await library.createPlaylist(
                            controller.text.trim());
                        Navigator.of(ctx).pop(meta.id);
                        if (confirm) {
                          AppSnackbar.show(AppConstants.playlistCreated(meta.title));
                        }
                      }
                    },
                    child: Text(
                      AppConstants.createPlaylist,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
