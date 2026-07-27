import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_playlist_meta.dart';
import '../models/saved_item_model.dart';

class LibraryController extends GetxController {
  static const _favKey = 'avvento_favorites';
  static const _playlistMetaKey = 'avvento_custom_playlists_meta';
  static String _playlistItemsKey(String id) => 'avvento_playlist_$id';

  final RxList<SavedItem> favorites = <SavedItem>[].obs;
  final RxList<CustomPlaylistMeta> playlists = <CustomPlaylistMeta>[].obs;

  int get favoritesCount => favorites.length;
  int get playlistsCount => playlists.length;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  // ─── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    // Load favorites
    final favJson = prefs.getString(_favKey);
    if (favJson != null) {
      final List<dynamic> list = jsonDecode(favJson) as List<dynamic>;
      favorites.assignAll(
          list.map((e) => SavedItem.fromJson(e as Map<String, dynamic>)));
    }

    // Load playlist metadata
    final metaJson = prefs.getString(_playlistMetaKey);
    if (metaJson != null) {
      final List<dynamic> list = jsonDecode(metaJson) as List<dynamic>;
      playlists.assignAll(list
          .map((e) => CustomPlaylistMeta.fromJson(e as Map<String, dynamic>)));
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _favKey, jsonEncode(favorites.map((e) => e.toJson()).toList()));
  }

  Future<void> _savePlaylistMeta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _playlistMetaKey, jsonEncode(playlists.map((e) => e.toJson()).toList()));
  }

  Future<void> _savePlaylistItems(
      String playlistId, List<SavedItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistItemsKey(playlistId),
        jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // ─── Favorites ──────────────────────────────────────────────────────────────

  bool isFavorite(String id) => favorites.any((f) => f.id == id);

  /// Returns true if added, false if removed (toggle).
  Future<bool> toggleFavorite(SavedItem item) async {
    final idx = favorites.indexWhere((f) => f.id == item.id);
    if (idx >= 0) {
      favorites.removeAt(idx);
      await _saveFavorites();
      return false;
    } else {
      favorites.insert(0, item);
      await _saveFavorites();
      return true;
    }
  }

  Future<void> removeFavorite(String id) async {
    favorites.removeWhere((f) => f.id == id);
    await _saveFavorites();
  }

  /// Favorites grouped by groupTitle (preserving insertion order of groups).
  Map<String, List<SavedItem>> get favoritesGrouped {
    final map = <String, List<SavedItem>>{};
    for (final item in favorites) {
      map.putIfAbsent(item.groupTitle, () => []).add(item);
    }
    return map;
  }

  // ─── Custom Playlists ────────────────────────────────────────────────────────

  Future<CustomPlaylistMeta> createPlaylist(String title) async {
    final id = 'pl_${DateTime.now().millisecondsSinceEpoch}';
    final meta = CustomPlaylistMeta(
        id: id, title: title, createdAt: DateTime.now());
    playlists.insert(0, meta);
    await _savePlaylistMeta();
    return meta;
  }

  Future<void> editPlaylist(String playlistId, String newTitle) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx >= 0) {
      final oldMeta = playlists[idx];
      playlists[idx] = CustomPlaylistMeta(
        id: oldMeta.id,
        title: newTitle,
        createdAt: oldMeta.createdAt,
      );
      await _savePlaylistMeta();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylistMeta();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playlistItemsKey(playlistId));
  }

  Future<List<SavedItem>> getPlaylistItems(String playlistId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_playlistItemsKey(playlistId));
    if (json == null) return [];
    final List<dynamic> list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => SavedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns true if added, false if already exists.
  Future<bool> addToPlaylist(String playlistId, SavedItem item) async {
    final items = await getPlaylistItems(playlistId);
    if (items.any((i) => i.id == item.id)) return false;
    items.insert(0, item);
    await _savePlaylistItems(playlistId, items);
    return true;
  }

  Future<void> removeFromPlaylist(String playlistId, String itemId) async {
    final items = await getPlaylistItems(playlistId);
    items.removeWhere((i) => i.id == itemId);
    await _savePlaylistItems(playlistId, items);
  }

  /// Items in a playlist grouped by groupTitle.
  Map<String, List<SavedItem>> groupItems(List<SavedItem> items) {
    final map = <String, List<SavedItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.groupTitle, () => []).add(item);
    }
    return map;
  }

  /// Total items count across all playlists (async, used for badges).
  Future<int> totalPlaylistItemCount() async {
    int total = 0;
    for (final p in playlists) {
      final items = await getPlaylistItems(p.id);
      total += items.length;
    }
    return total;
  }
}
