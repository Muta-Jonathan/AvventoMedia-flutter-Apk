import 'dart:convert';

import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/utils.dart';
import '../controller/youtube_playlist_controller.dart';
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
  final List<String> _searchHistory = []; // Memory for last searches
  String _searchText = "";
  late List<dynamic> _content = [];
  final youtubePlaylistController = Get.put(YoutubePlaylistController());

  Future<void> loadCachedPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    // Filter keys starting with "cached_playlists_"
    final keys = prefs.getKeys().where((key) => key.startsWith('cached_playlists_')).toList();
    final List<dynamic> allPlaylists = [];

    for (var key in keys) {
      final String? cachedData = prefs.getString(key);
      if (cachedData != null) {
        final List<dynamic> playlistJsonList = jsonDecode(cachedData);

        // Identify the type of model stored and decode accordingly
        final List<dynamic> playlistsOrItems = playlistJsonList.map((json) {
          if (json['itemCount'] != null) {
            // If `etag` and `id` exist, it's a YoutubePlaylistModel
            return YoutubePlaylistModel.fromJson(json);
          } else if (json['videoId'] != null) {
            // If `videoId` exists, it's a YouTubePlaylistItemModel
            return YouTubePlaylistItemModel.fromJson(json);
          }
          return null; // Ignore invalid entries
        }).whereType<dynamic>().toList();

        allPlaylists.addAll(playlistsOrItems);
      }
    }

    // for (var key in keys) {
    //   final String? cachedData = prefs.getString(key);
    //   if (cachedData != null) {
    //     final List<dynamic> playlistJsonList = jsonDecode(cachedData);
    //     final List<YoutubePlaylistModel> playlists = playlistJsonList
    //         .map((json) => YoutubePlaylistModel.fromJson(json))
    //         .toList();
    //     allPlaylists.addAll(playlists);
    //   }
    // }

    setState(() {
      _content = allPlaylists;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCachedPlaylists();
  }

  // Dropdown filters state
  // String _selectedCategory = "Category";

  @override
  Widget build(BuildContext context) {
    final filteredContent = _content
        .where((item) =>
        item.title.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    hintText: "Search content",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Exit back to main page
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // _buildDropdown("Category", _selectedCategory, (value) {
                //   setState(() {
                //     _selectedCategory = value!;
                //   });
                // }),
              ],
            ),
          ),

          // Search History
          Expanded(
            child: _searchText.isEmpty
                ? _buildSearchHistory()
                : _buildSearchResults(filteredContent),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> filteredContent) {
    if (filteredContent.isEmpty) {
      return const Center(
        child: Text(
          "No results found.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredContent.length,
      itemBuilder: (context, index) {
        final item = filteredContent[index];
        return GestureDetector(
            onTap: () {
              // Set the selected youtube playlist using the controller
              youtubePlaylistController.setSelectedPlaylist(item);
              // Navigate to the "YoutubePlaylistPage"
              Get.toNamed(Routes.getYoutubeMusicPlaylistItemRoute());
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: AppConstants.leftMain,right: 8.0,top: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child:Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: AppConstants.rightMain),
                    ),
                    const SizedBox(height: 5,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: item.thumbnailUrl,
                            fit: BoxFit.cover,
                            width: Utils.calculateWidth(context, 0.36),
                            height:  Utils.calculateHeight(context, 0.094),
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                  width:  Utils.calculateWidth(context, 0.1),
                                  height:  Utils.calculateWidth(context, 0.1),
                                  child: const LoadingWidget()
                              ),
                            ),
                            errorWidget: (context, _, error) => Icon(
                              Icons.error,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Utils.calculateWidth(context,0.52),
                              child: TextOverlay(
                                label: item.title,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: Utils.calculateWidth(context,0.042),
                              ),
                            ),
                            const SizedBox(height: 2),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                color: Theme.of(context).colorScheme.tertiaryContainer,
                                padding: const EdgeInsets.all(3.5),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icon/folder.svg',
                                      color:  Theme.of(context).colorScheme.onSecondary,
                                      width: 20,
                                      height: 20,
                                    ),
                                    TextOverlay(
                                      label: item.itemCount.toString(),
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
        );
      },
    );
  }

  Widget _buildSearchHistory() {
    return ListView(
      children: [
        if (_searchHistory.isNotEmpty)
          ..._searchHistory.map(
                (term) => ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(term),
              onTap: () {
                setState(() {
                  _searchText = term;
                  _searchController.text = term;
                });
              },
            ),
          ),
        if (_searchHistory.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No search history yet",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildDropdown(
  //     String label, String value, ValueChanged<String?> onChanged) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(25.0),
  //     child: Container(
  //       color: Theme.of(context).colorScheme.secondary,
  //       padding: const EdgeInsets.all(8),
  //       height: 40,
  //       child: DropdownButton<String>(
  //         value: value,
  //         underline: const SizedBox(),
  //         items: [label, "Live", "Avvento Music", "Avvento Kids", "Avvento Productions"]
  //             .map((item) => DropdownMenuItem<String>(
  //           value: item,
  //           child: Text(
  //             item,
  //             style: TextStyle(
  //               color: item == label ? Colors.yellow[700] : Theme.of(context).colorScheme.onPrimary,
  //               fontWeight:
  //               item == label ? FontWeight.bold : FontWeight.normal,
  //             ),
  //           ),
  //         ))
  //             .toList(),
  //         onChanged: onChanged,
  //         icon: Icon(Icons.arrow_drop_down, color: Colors.yellow[700]),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}