import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../components/library_navigation.dart';
import '../controller/library_controller.dart';
import '../models/saved_item_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        title: Text(
          AppConstants.favorites,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: Obx(() {
        if (library.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.heart,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  AppConstants.noFavorites,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final grouped = library.favoritesGrouped;
        final groups = grouped.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: groups.fold<int>(
              0, (sum, e) => sum + 1 + e.value.length), // headers + items
          itemBuilder: (context, idx) {
            // Flatten grouped data into a sequential list
            int cursor = 0;
            for (final entry in groups) {
              if (idx == cursor) {
                // Section header
                return _SectionHeader(title: entry.key);
              }
              cursor++;
              final items = entry.value;
              if (idx < cursor + items.length) {
                final item = items[idx - cursor];
                return _SavedItemTile(
                  item: item,
                  onRemove: () => library.removeFavorite(item.id),
                );
              }
              cursor += items.length;
            }
            return const SizedBox.shrink();
          },
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SavedItemTile extends StatelessWidget {
  final SavedItem item;
  final VoidCallback onRemove;
  const _SavedItemTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LibraryNavigation.navigateToSavedItem(item),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        trailing: IconButton(
          icon: const Icon(CupertinoIcons.heart_fill, color: Colors.redAccent),
          tooltip: 'Remove from favorites',
          onPressed: onRemove,
        ),
      ),
    );
  }
}
