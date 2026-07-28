import 'package:avvento_media/apis/firestore_service_api.dart';
import 'package:avvento_media/components/responsive_helper.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/controller/youtube_playlist_item_controller.dart';
import 'package:avvento_media/models/highlightmodel/highlight_model.dart';
import 'package:avvento_media/pages/search_page.dart';
import 'package:avvento_media/routes/routes.dart';
import 'package:avvento_media/widgets/hightlights/hightlights_widget.dart';
import 'package:avvento_media/widgets/hightlights/tv_highlights_carousel.dart';
import 'package:avvento_media/widgets/radio/live_radio_widget.dart';
import 'package:avvento_media/widgets/tv/tv_hero_banner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final _highlightsAPI = Get.put(FirestoreServiceAPI());
  final youtubePlaylistItemController = Get.put(YoutubePlaylistItemController());
  final youtubePlaylistController = Get.put(YoutubePlaylistController());

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.tv) {
          return _buildTvHomePage(context);
        } else {
          return _buildStandardHomePage(context);
        }
      },
    );
  }

  Widget _buildStandardHomePage(BuildContext context) {
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
                Text(
                  AppConstants.appName,
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(
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
          ),
        ],
      ),
    );
  }

  Widget _buildTvHomePage(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<QuerySnapshot>(
        stream: _highlightsAPI.fetchHighlights(),
        builder: (context, snapshot) {
          HighlightModel? topHighlight;
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            topHighlight = HighlightModel.fromSnapShot(snapshot.data!.docs.first);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            child: Column(
              children: [
                // Content Shelves
                const TvHighlightsCarouselWidget(),
                const SizedBox(height: 30),
                const LiveTvWidget(),
                const SizedBox(height: 30),
                const LiveRadioWidget(),
                const SizedBox(height: 30),
                const YoutubeMusicPlaylistWidget(),
                const SizedBox(height: 30),
                const YoutubeKidsPlaylistWidget(),
                const SizedBox(height: 30),
                const YoutubeMainPlaylistWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleHighlightClick(HighlightModel? highlightModel) {
    if (highlightModel == null) return;
    if (highlightModel.youtubePlaylistItem != null) {
      youtubePlaylistItemController.setSelectedEpisode(highlightModel.youtubePlaylistItem);
      Get.toNamed(Routes.getWatchYoutubeRoute());
    } else if (highlightModel.youtubePlaylist != null) {
      youtubePlaylistController.setSelectedPlaylist(highlightModel.youtubePlaylist);
      if (highlightModel.type == AppConstants.avventoMusic) {
        Get.toNamed(Routes.getYoutubeMusicPlaylistItemRoute());
      } else if (highlightModel.type == AppConstants.avventoKids) {
        Get.toNamed(Routes.getYoutubeKidsPlaylistItemRoute());
      } else {
        Get.toNamed(Routes.getYoutubeMainPlaylistItemRoute());
      }
    }
  }
}
