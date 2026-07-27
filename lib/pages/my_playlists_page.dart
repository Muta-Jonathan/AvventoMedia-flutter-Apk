import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../controller/library_controller.dart';
import '../widgets/common/new_playlist_bottom_sheet.dart';
import 'playlist_detail_page.dart';

class MyPlaylistsPage extends StatelessWidget {
  const MyPlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        title: Text(
          AppConstants.myPlaylists,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            tooltip: AppConstants.newPlaylist,
            onPressed: () => NewPlaylistBottomSheet.show(context),
          ),
        ],
      ),
      body: Obx(() {
        if (library.playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.playlist_play,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  AppConstants.noPlaylists,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(CupertinoIcons.add),
                  label: Text(AppConstants.newPlaylist),
                  onPressed: () => NewPlaylistBottomSheet.show(context),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: library.playlists.length,
          itemBuilder: (context, index) {
            final pl = library.playlists[index];
            return Dismissible(
              key: ValueKey(pl.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.withOpacity(0.8),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor:
                        Theme.of(context).colorScheme.surface,
                    title: Text('Delete "${pl.title}"?',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onPrimary)),
                    content: Text(
                      'This will permanently delete the playlist and all its items.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ) ?? false;
              },
              onDismissed: (_) async {
                await library.deletePlaylist(pl.id);
                Get.snackbar('', AppConstants.playlistDeleted,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.grey.withOpacity(0.8),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 12,
                    duration: const Duration(seconds: 2));
              },
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.playlist_play,
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
                title: Text(
                  pl.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                      onPressed: () {
                        final ctrl = TextEditingController(text: pl.title);
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            title: Text('Rename Playlist', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                            content: TextField(
                              controller: ctrl,
                              autofocus: true,
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                              decoration: InputDecoration(
                                hintText: 'Playlist name',
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  final newName = ctrl.text.trim();
                                  if (newName.isNotEmpty) {
                                    library.editPlaylist(pl.id, newName);
                                    Navigator.pop(ctx);
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Icon(CupertinoIcons.chevron_forward,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 18),
                  ],
                ),
                onTap: () {
                  Get.to(() => PlaylistDetailPage(playlist: pl));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
