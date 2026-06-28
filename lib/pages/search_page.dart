import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/live_tv_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/firestore_service_api.dart';
import '../controller/radio_controller.dart';
import '../controller/youtube_playlist_controller.dart';
import '../controller/youtube_playlist_item_controller.dart';
import '../models/livetvmodel/livetv_model.dart';
import '../models/radiomodel/radio_model.dart';
import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';
import '../routes/routes.dart';
import '../widgets/common/loading_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  String _searchText = "";

  /// Cached content = playlists + items + highlights + liveTv + radio
  List<dynamic> _content = [];
  // Currently selected category filter
  String? _selectedCategory; // null = all

  final List<String> _categories = [
    "Playlist",
    "Video",
    "Live" // Live = TV + Radio
  ];
  String? _selectedSubCategory;

  final youtubePlaylistController = Get.put(YoutubePlaylistController());
  final youtubeItemController = Get.put(YoutubePlaylistItemController());
  final liveTvController = Get.put(LiveTvController());
  final radioController = Get.put(RadioController());



  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadAllCachedContent();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String term) async {
    if (term.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(term);
      _searchHistory.insert(0, term);
      if (_searchHistory.length > 20) _searchHistory.removeLast();
    });
    await prefs.setStringList('search_history', _searchHistory);
  }

  Future<void> _deleteSearchHistory(String term) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(term);
    });
    await prefs.setStringList('search_history', _searchHistory);
  }

  Future<void> _loadAllCachedContent() async {
    final api = FirestoreServiceAPI.instance;
    final List<dynamic> loaded = [];


    // All your channel names
    final List<String> channelNames = [
      AppConstants.avventoKidsChannel,
      AppConstants.avventoMusicChannel,
      AppConstants.avventoMainChannel,
    ];

    // LOAD DATA FROM CACHE (no internet needed)
    loaded.addAll(await api.loadLiveTvOffline());
    loaded.addAll(await api.loadRadioOffline());

    // Load playlists + items for each channel
    for (final channelName in channelNames) {
      // Load playlists
      final playlists = await api.loadPlaylistsOffline(channelName);
      loaded.addAll(playlists);

      // Load items for each playlist
      for (final playlist in playlists) {
        final items = await api.loadPlaylistItemsOffline(channelName, playlist.id);
        loaded.addAll(items);
      }
    }

    setState(() => _content = loaded);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: _buildSearchBar(context),
      body: Column(
        children: [
          _buildCategoryChips(),
          const SizedBox(height: 8),
          Expanded(
            child: _searchText.isEmpty
                ? _buildSearchHistory()
                : _buildResults(_filterByCategory()),
          ),
        ],
      ),
    );
  }

  // ---------------- UI COMPONENTS ----------------

  PreferredSizeWidget _buildSearchBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Row(
        children: [
          Expanded(child: _buildSearchInput(context)),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              AppConstants.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchText = value),
        onSubmitted: (value) => _saveSearchHistory(value),
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          hintText: AppConstants.searchContent,
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
          prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey.withValues(alpha: 0.6), size: 20),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.grey, size: 20),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchText = "";
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(AppConstants.noResults, style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (_, index) => _buildResultTile(list[index]),
    );
  }

  Widget _buildResultTile(dynamic item) {
    return GestureDetector(
      onTap: () {
        _saveSearchHistory(_searchText);
        _openItem(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(item),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildTextSection(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(item) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          child: CachedNetworkImage(
            imageUrl: getItemThumbnail(item),
            fit: BoxFit.cover,
            width: 130,
            height: 90,
            placeholder: (_, __) => const SizedBox(width: 130, height: 90, child: LoadingWidget()),
            errorWidget: (_, __, ___) => Container(width: 130, height: 90, color: Colors.grey.withValues(alpha: 0.2), child: const Icon(Icons.error)),
          ),
        ),
        if (item is YouTubePlaylistItemModel)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.play_arrow_solid, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextSection(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getItemTitle(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        _buildMeta(item),
      ],
    );
  }

  Widget _buildMeta(dynamic item) {
    if (item is YoutubePlaylistModel) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.folder_fill, size: 12, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              "${item.itemCount} videos",
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
    } else if (item is YouTubePlaylistItemModel) {
      return Text(
        item.duration,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: 12,
        ),
      );
    } else if (item is LiveTvModel || item is RadioModel) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: const Text(
          "LIVE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return const Center(
        child: Text(AppConstants.noSearchResults, style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final term = _searchHistory[index];
        return ListTile(
          leading: const Icon(CupertinoIcons.time, color: Colors.grey),
          title: Text(term, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.clear, color: Colors.grey, size: 18),
            onPressed: () => _deleteSearchHistory(term),
          ),
          onTap: () {
            _searchController.text = term;
            setState(() => _searchText = term);
            _saveSearchHistory(term);
          },
        );
      },
    );
  }

  Widget _buildCategoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: _categories.map((category) {
              final bool isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedCategory == category) {
                        _selectedCategory = null;
                        _selectedSubCategory = null;
                      } else {
                        _selectedCategory = category;
                        _selectedSubCategory = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.onSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Sub Categories
        if (_selectedCategory != null && _getSubCategories(_selectedCategory!).isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: _getSubCategories(_selectedCategory!).map((subCat) {
                  final bool isSelected = _selectedSubCategory == subCat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedSubCategory == subCat) {
                            _selectedSubCategory = null;
                          } else {
                            _selectedSubCategory = subCat;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          subCat,
                          style: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  List<String> _getSubCategories(String category) {
    switch (category) {
      case "Playlist":
      case "Video":
        return [AppConstants.avventoKidsChannel, AppConstants.avventoMusicChannel, AppConstants.avventoMainChannel];
      case "Live":
        return ["TV", "Radio"];
      default:
        return [];
    }
  }

  // ---------------- LOGIC ----------------

  void _openItem(dynamic item) async {
    if (item is YoutubePlaylistModel) {
      youtubePlaylistController.setSelectedPlaylist(item);

      if (item.channelName == AppConstants.avventoKidsChannel) {
        Get.toNamed(Routes.getYoutubeKidsPlaylistItemRoute());
      }
      else if (item.channelName == AppConstants.avventoMusicChannel) {
        Get.toNamed(Routes.getYoutubeMusicPlaylistItemRoute());
      }
      else {
        Get.toNamed(Routes.getYoutubeMainPlaylistItemRoute());
      }
    } else if (item is YouTubePlaylistItemModel) {
      youtubeItemController.setSelectedEpisode(item);
      Get.toNamed(Routes.getWatchYoutubeRoute());
    } else if (item is LiveTvModel) {
      liveTvController.selectedTv(item);
      Get.toNamed(Routes.getLiveTvRoute());
    } else if (item is RadioModel) {
      radioController.selectedRadio(item);
      Get.toNamed(Routes.getListenRoute());
    }
  }

  String getItemTitle(dynamic item) {
    if (item is YoutubePlaylistModel) return item.title;
    if (item is YouTubePlaylistItemModel) return item.title;
    if (item is LiveTvModel) return item.name;
    if (item is RadioModel) return item.name;
    return '';
  }

  String getItemThumbnail(dynamic item) {
    if (item is YoutubePlaylistModel) return item.thumbnailUrl;
    if (item is YouTubePlaylistItemModel) return item.thumbnailUrl;
    if (item is LiveTvModel) return item.imageUrl;
    if (item is RadioModel) return item.imageUrl;
    return '';
  }

  List<dynamic> _filterByCategory() {
    List<dynamic> filtered = _content
        .where((item) =>
        getItemTitle(item)
            .toLowerCase()
            .contains(_searchText.toLowerCase()))
        .toList();

    if (_selectedCategory != null) {
      if (_selectedCategory == "Playlist") {
        filtered = filtered.whereType<YoutubePlaylistModel>().toList();
      } else if (_selectedCategory == "Video") {
        filtered = filtered.whereType<YouTubePlaylistItemModel>().toList();
      } else if (_selectedCategory == "Live") {
        filtered = filtered.where((item) => item is LiveTvModel || item is RadioModel).toList();
      }
    }

    if (_selectedSubCategory != null) {
      switch (_selectedSubCategory) {
        case "TV":
          filtered = filtered.whereType<LiveTvModel>().toList();
          break;
        case "Radio":
          filtered = filtered.whereType<RadioModel>().toList();
          break;
        case AppConstants.avventoKidsChannel:
        case AppConstants.avventoMusicChannel:
        case AppConstants.avventoMainChannel:
          filtered = filtered.where((item) {
            if (item is YoutubePlaylistModel) return item.channelName == _selectedSubCategory;
            if (item is YouTubePlaylistItemModel) return item.channelName == _selectedSubCategory;
            return false;
          }).toList();
          break;
      }
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
