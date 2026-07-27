import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/library_navigation.dart';
import '../controller/library_controller.dart';
import '../models/custom_playlist_meta.dart';
import '../models/saved_item_model.dart';

class PlaylistDetailPage extends StatefulWidget {
  final CustomPlaylistMeta playlist;
  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late LibraryController _library;
  List<SavedItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _library = Get.find<LibraryController>();
    _load();
  }

  Future<void> _load() async {
    final items = await _library.getPlaylistItems(widget.playlist.id);
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  Map<String, List<SavedItem>> get _grouped => _library.groupItems(_items);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        title: Text(
          widget.playlist.title,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.music_note_list,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No items in this playlist',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildGroupedList(context),
    );
  }

  Widget _buildGroupedList(BuildContext context) {
    final grouped = _grouped;
    final groups = grouped.entries.toList();

    final flatItems = <dynamic>[]; // String (header) | SavedItem
    for (final entry in groups) {
      flatItems.add(entry.key); // header
      flatItems.addAll(entry.value);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: flatItems.length,
      itemBuilder: (context, idx) {
        final e = flatItems[idx];
        if (e is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
            child: Text(
              e,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          );
        }
        final item = e as SavedItem;
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red.withOpacity(0.8),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) async {
            await _library.removeFromPlaylist(widget.playlist.id, item.id);
            setState(() => _items.removeWhere((i) => i.id == item.id));
            Get.snackbar('', 'Removed from playlist',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.grey.withOpacity(0.8),
                colorText: Colors.white,
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
                duration: const Duration(seconds: 2));
          },
          child: InkWell(
            onTap: () => LibraryNavigation.navigateToSavedItem(item),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.thumbnailUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(CupertinoIcons.photo, size: 40),
                      )
                    : const Icon(CupertinoIcons.photo, size: 40),
              ),
              title: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.groupTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (item.duration != null && item.duration!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.duration!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
