import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/live_tv_controller.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../apis/firestore_service_api.dart';
import '../components/utils.dart';
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
  final List<String> _searchHistory = [];
  String _searchText = "";

  /// Cached content = playlists + items + highlights + liveTv + radio
  List<dynamic> _content = [];

  final youtubePlaylistController = Get.put(YoutubePlaylistController());
  final youtubeItemController = Get.put(YoutubePlaylistItemController());
  final liveTvController = Get.put(LiveTvController());
  final radioController = Get.put(RadioController());



  @override
  void initState() {
    super.initState();
    _loadAllCachedContent();
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
    final filtered = _content
        .where((item) => getItemTitle(item).toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: _buildSearchBar(context),
      body: Column(
        children: [
          Expanded(
            child: _searchText.isEmpty
                ? _buildSearchHistory()
                : _buildResults(filtered),
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
      height: 40,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchText = value),
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: AppConstants.searchContent,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchText = "";
              });
            },
          )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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
      onTap: () => _openItem(item),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
          left: AppConstants.leftMain,
          right: 8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              _buildThumbnail(item),
              const SizedBox(width: 12),
              _buildTextSection(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: getItemThumbnail(item),
        fit: BoxFit.cover,
        width: Utils.calculateWidth(context, 0.36),
        height: Utils.calculateHeight(context, 0.094),
        placeholder: (_, __) => const LoadingWidget(),
        errorWidget: (_, __, ___) => const Icon(Icons.error),
      ),
    );
  }

  Widget _buildTextSection(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Utils.calculateWidth(context, 0.52),
          child: TextOverlay(
            label: getItemTitle(item),
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: Utils.calculateWidth(context, 0.042),
          ),
        ),
        const SizedBox(height: 5),
        _buildMeta(item),
      ],
    );
  }

  Widget _buildMeta(dynamic item) {
    if (item is YoutubePlaylistModel) {
      // Playlist → show itemCount with folder
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icon/folder.svg',
              width: 20,
            ),
            const SizedBox(width: 5),
            Text(
              item.itemCount.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 14,
              ),
            )
          ],
        ),
      );
    } else if (item is YouTubePlaylistItemModel) {
      // Playlist item → show duration without container
      return Text(
        item.duration,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 12,
        ),
      );
    } else if (item is LiveTvModel || item is RadioModel) {
      // Live TV or Radio → show LIVE in red container
      return Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: const Text(
          AppConstants.live,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return const Center(
        child: Text(AppConstants.noSearchResults, style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      children: _searchHistory.map((term) {
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title: Text(term),
          onTap: () {
            _searchController.text = term;
            setState(() => _searchText = term);
          },
        );
      }).toList(),
    );
  }

  // ---------------- LOGIC ----------------

  void _openItem(dynamic item) async {
    if (item is YoutubePlaylistModel) {
      youtubePlaylistController.setSelectedPlaylist(item);
      Get.toNamed(Routes.getYoutubeKidsPlaylistItemRoute());
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
