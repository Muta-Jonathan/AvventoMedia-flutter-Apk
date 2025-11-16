import 'package:avvento_media/pages/search_page.dart';
import 'package:avvento_media/widgets/hightlights/hightlights_widget.dart';
import 'package:avvento_media/widgets/radio/live_radio_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/app_constants.dart';
import '../widgets/liveTv/horizontal/live_tv_widget.dart';
import '../widgets/youtube/playlist/horizontal/youtube_kids_playlist_widget.dart';
import '../widgets/youtube/playlist/horizontal/youtube_main_playlist_widget.dart';
import '../widgets/youtube/playlist/horizontal/youtube_music_playlist_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              floating: true,
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
              actions: [
                IconButton(
                  icon: Icon(CupertinoIcons.search, color: Theme.of(context).colorScheme.onPrimary),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  HightlightsWidget(),
                  SizedBox(height: 30,),
                  LiveTvWidget(),
                  SizedBox(height: 30,),
                  LiveRadioWidget(),
                  SizedBox(height: 30,),
                  YoutubeMusicPlaylistWidget(),
                  SizedBox(height: 30,),
                  YoutubeKidsPlaylistWidget(),
                  SizedBox(height: 30,),
                  YoutubeMainPlaylistWidget(),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
