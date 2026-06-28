import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../controller/library_controller.dart';
import '../../models/saved_item_model.dart';
import 'new_playlist_bottom_sheet.dart';

class SaveBottomSheet {
  static void show(BuildContext context, SavedItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SaveBottomSheetContent(item: item),
    );
  }
}

class _SaveBottomSheetContent extends StatefulWidget {
  final SavedItem item;
  const _SaveBottomSheetContent({required this.item});

  @override
  State<_SaveBottomSheetContent> createState() =>
      _SaveBottomSheetContentState();
}

class _SaveBottomSheetContentState extends State<_SaveBottomSheetContent> {
  late LibraryController _library;
  Map<String, bool> _playlistContains = {};

  @override
  void initState() {
    super.initState();
    _library = Get.find<LibraryController>();
    _loadPlaylistStates();
  }

  Future<void> _loadPlaylistStates() async {
    final result = <String, bool>{};
    for (final pl in _library.playlists) {
      final items = await _library.getPlaylistItems(pl.id);
      result[pl.id] = items.any((i) => i.id == widget.item.id);
    }
    if (mounted) setState(() => _playlistContains = result);
  }

  void _snack(String msg, {bool success = true}) {
    Get.snackbar(
      '',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          (success ? Colors.green : Colors.orange).withOpacity(0.85),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  String get _titleString {
    if (widget.item.type == 'video') return 'Save video to...';
    if (widget.item.type == 'playlist') return 'Save playlist to...';
    return 'Save podcast to...';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final playlists = _library.playlists.toList();

      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _titleString,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final id = await NewPlaylistBottomSheet.show(context);
                      if (id != null) {
                        final added = await _library.addToPlaylist(id, widget.item);
                        if (added) _snack(AppConstants.savedToPlaylist);
                      }
                    },
                    icon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.amber, size: 28),
                    tooltip: AppConstants.newPlaylist,
                  )
                ],
              ),
              const SizedBox(height: 10),
              // Title row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.item.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            widget.item.thumbnailUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(CupertinoIcons.music_note, size: 40),
                          )
                        : const Icon(CupertinoIcons.music_note, size: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.item.groupTitle,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                  color: Theme.of(context)
                      .colorScheme
                      .tertiaryContainer),
              
              // ── Checkbox List ──────────────────────────────────────

              
              ...playlists.map((pl) {
                final inPlaylist = _playlistContains[pl.id] ?? false;
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: inPlaylist,
                  activeColor: Colors.amber,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  title: Text(
                    pl.title,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  onChanged: (val) async {
                    if (val == true) {
                      final added = await _library.addToPlaylist(pl.id, widget.item);
                      if (added) {
                        setState(() => _playlistContains[pl.id] = true);
                        _snack(AppConstants.savedToPlaylist);
                      }
                    } else {
                      await _library.removeFromPlaylist(pl.id, widget.item.id);
                      setState(() => _playlistContains[pl.id] = false);
                      _snack('Removed from playlist', success: false);
                    }
                  },
                );
              }),
            ],
          );
        },
      );
    });
  }
}
