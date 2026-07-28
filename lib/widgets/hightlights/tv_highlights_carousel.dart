import 'dart:async';
import 'package:avvento_media/models/highlightmodel/highlight_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/tv/tv_hero_banner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../apis/firestore_service_api.dart';
import '../../components/app_constants.dart';
import '../../controller/youtube_playlist_controller.dart';
import '../../controller/youtube_playlist_item_controller.dart';
import '../../routes/routes.dart';

class TvHighlightsCarouselWidget extends StatefulWidget {
  const TvHighlightsCarouselWidget({super.key});

  @override
  State<TvHighlightsCarouselWidget> createState() => _TvHighlightsCarouselWidgetState();
}

class _TvHighlightsCarouselWidgetState extends State<TvHighlightsCarouselWidget> {
  final _highlightsAPI = Get.put(FirestoreServiceAPI());
  final youtubePlaylistItemController = Get.put(YoutubePlaylistItemController());
  final youtubePlaylistController = Get.put(YoutubePlaylistController());
  
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _currentIndex = 0;
  Timer? _autoSlideTimer;
  List<HighlightModel> _items = [];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_items.isEmpty) return;
      int nextPage = (_currentIndex + 1) % _items.length;
      if (_controller.hasClients) {
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _handleHighlightClick(HighlightModel highlightModel) {
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
      stream: _highlightsAPI.fetchHighlights(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: screenHeight * 0.55,
            child: const Center(child: LoadingWidget()),
          );
        }

        _items = snapshot.data!.docs.map((doc) => HighlightModel.fromSnapShot(doc)).toList();

        if (_items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            SizedBox(
              height: screenHeight * 0.55,
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TvHeroBanner(
                      highlightItem: item,
                      onPlayPressed: () => _handleHighlightClick(item),
                      isActive: _currentIndex == index,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
