import 'package:avvento_media/pages/search_page.dart';
import 'package:avvento_media/widgets/hightlights/hightlights_widget.dart';
import 'package:avvento_media/widgets/radio/live_radio_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/app_constants.dart';
import '../widgets/common/filter_chips_bar.dart';
import '../widgets/liveTv/horizontal/live_tv_widget.dart';
import '../widgets/youtube/playlist/horizontal/youtube_kids_playlist_widget.dart';
import '../widgets/youtube/playlist/horizontal/youtube_main_playlist_widget.dart';
import '../widgets/youtube/playlist/horizontal/youtube_music_playlist_widget.dart';
import 'favorites_page.dart';
import 'my_playlists_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _sections = [
    AppConstants.homeCatalog,
    AppConstants.favorites,
    AppConstants.homePlaylists,
  ];

  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Title + chips float away on scroll in every section.
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            floating: true,
            iconTheme: IconThemeData(color: onPrimary),
            actions: [
              IconButton(
                icon: Icon(CupertinoIcons.search, color: onPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
              )
            ],
            title: Column(
              children: [
                const SizedBox(height: 15),
                Text(AppConstants.appName,
                    style: TextStyle(color: onPrimary)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(FilterChipsBar.height),
              child: FilterChipsBar(
                labels: _sections,
                selected: _section,
                onSelected: (i) => setState(() => _section = i),
              ),
            ),
          ),
        ],
        // IndexedStack keeps each section's scroll position and loaded
        // catalog while switching chips.
        body: IndexedStack(
          index: _section,
          children: const [
            _CatalogView(),
            FavoritesView(),
            PlaylistsView(showCreateRow: true),
          ],
        ),
      ),
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        children: [
          HightlightsWidget(),
          SizedBox(height: 30),
          LiveTvWidget(),
          SizedBox(height: 30),
          LiveRadioWidget(),
          SizedBox(height: 30),
          YoutubeMusicPlaylistWidget(),
          SizedBox(height: 30),
          YoutubeKidsPlaylistWidget(),
          SizedBox(height: 30),
          YoutubeMainPlaylistWidget(),
        ],
      ),
    );
  }
}
