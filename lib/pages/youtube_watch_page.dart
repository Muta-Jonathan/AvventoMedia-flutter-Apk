import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/controller/youtube_playlist_item_controller.dart';
import 'package:avvento_media/models/saved_item_model.dart';
import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import '../widgets/common/favorite_button.dart';
import '../widgets/common/save_button.dart';
import 'package:avvento_media/widgets/common/share_button.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:avvento_media/widgets/youtube/items/youtube_playlist_item_details_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../apis/firestore_service_api.dart';
import '../components/utils.dart';
import '../widgets/text/show_more_desc.dart';

class YoutubeWatchPage extends StatefulWidget {
  const YoutubeWatchPage({super.key});

  @override
  State<YoutubeWatchPage> createState() => _YoutubeWatchPageState();
}

class _YoutubeWatchPageState extends State<YoutubeWatchPage> {
  final YoutubePlaylistItemController youtubePlaylistItemController = Get.find();
  final YoutubePlaylistController youtubePlaylistController = Get.find();
  late YoutubePlayerController _controller;
  bool isPlayerReady = false;

  // Related videos
  List<YouTubePlaylistItemModel> _relatedVideos = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    final selected = youtubePlaylistItemController.selectedPlaylistItem.value!;

    _controller = YoutubePlayerController(
      initialVideoId: selected.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
        forceHD: true,
        enableCaption: false,
        isLive: selected.liveBroadcastContent == 'live',
        useHybridComposition: true,
      ),
    );

    // Allow immersive fullscreen when rotated
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Fetch related videos from the same playlist
    _fetchRelatedVideos();
  }

  void _fetchRelatedVideos() {
    final selectedPlaylist = youtubePlaylistController.selectedPlaylist.value;
    final selectedItem = youtubePlaylistItemController.selectedPlaylistItem.value;

    if (selectedPlaylist == null || selectedItem == null) {
      setState(() => _isLoadingRelated = false);
      return;
    }

    // Determine channel name from the playlist model or fall back to item's channelName
    final channelName = selectedPlaylist.channelName.isNotEmpty
        ? selectedPlaylist.channelName
        : selectedItem.channelName.isNotEmpty
            ? selectedItem.channelName
            : AppConstants.avventoMainChannel;

    final firestoreAPI = FirestoreServiceAPI.instance;
    firestoreAPI
        .streamPlaylistItems(channelName, selectedPlaylist.id)
        .listen((items) {
      if (mounted) {
        // Filter out the currently playing video, shuffle, and take up to 12
        final filtered = items
            .where((item) =>
                item.videoId != selectedItem.videoId &&
                item.title != 'Private video' &&
                item.privacyStatus != 'unlisted')
            .toList();
        filtered.shuffle();
        setState(() {
          _relatedVideos = filtered.take(12).toList();
          _isLoadingRelated = false;
        });
      }
    }, onError: (_) {
      if (mounted) setState(() => _isLoadingRelated = false);
    });
  }

  void _onRelatedVideoTap(YouTubePlaylistItemModel item) {
    // Update the selected item
    youtubePlaylistItemController.setSelectedEpisode(item);
    // Load the new video in the existing player
    _controller.load(item.videoId);
    // Refresh related videos
    setState(() {
      _isLoadingRelated = true;
    });
    _fetchRelatedVideos();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          progressColors: ProgressBarColors(
            playedColor: Colors.amber,
            handleColor: Colors.amber,     // thumb color
            bufferedColor: Colors.grey,
            backgroundColor: Colors.grey[600],
          ),
          onReady: () {
            setState(() {
              isPlayerReady = true;
            });
          },
          ),
            builder: (context, player) {
              return Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: player,
                        ),
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Material(
                            color: Colors.black38,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Get.back(),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  CupertinoIcons.chevron_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      final selectedItem = youtubePlaylistItemController.selectedPlaylistItem.value;
                      if (selectedItem == null) return const SizedBox.shrink();

                      final int views = int.tryParse(selectedItem.views) ?? 0;
                      String view = Utils.formatViews(views);
                      String publishedDate = Jiffy.parseFromDateTime(selectedItem.publishedAt).fromNow();

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Video info section ---
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12,),
                                  TextOverlay(label: selectedItem.title,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: AppConstants.fontSize20,
                                    maxLines: 3,
                                  ),
                                  TextOverlay(label: 'from  ${selectedItem.channelTitle}',
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontSize: 15,
                                  ),
                                  const SizedBox(height: 8,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      (selectedItem.liveBroadcastContent == 'live' ||
                                          selectedItem.liveBroadcastContent == 'upcoming' ||
                                          view == 'No views') ?
                                      const SizedBox.shrink() :
                                      Row(
                                        children: [
                                          TextOverlay(label: view,
                                            color: Theme.of(context).colorScheme.onSecondary,
                                            fontSize: 15,
                                          ),
                                          TextOverlay(
                                            label: "  $publishedDate",
                                            fontSize: 14,
                                            color: Theme.of(context).colorScheme.onSecondary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            ShareButton(onShareTap: (){ Utils.shareYouTubeVideo(selectedItem.videoId); }),
                                            const SizedBox(width: 12),
                                            ValueListenableBuilder<YoutubePlayerValue>(
                                              valueListenable: _controller,
                                              builder: (context, value, _) {
                                                final currentDuration = _controller.metadata.duration;
                                                final itemToSave = SavedItem(
                                                  id: selectedItem.id,
                                                  type: 'video',
                                                  title: selectedItem.title,
                                                  thumbnailUrl: selectedItem.thumbnailUrl,
                                                  groupId: selectedItem.channelTitle,
                                                  groupTitle: selectedItem.channelTitle,
                                                  videoId: selectedItem.videoId,
                                                  duration: currentDuration.inSeconds > 0 
                                                      ? '${currentDuration.inMinutes}:${(currentDuration.inSeconds % 60).toString().padLeft(2, '0')}' 
                                                      : Utils.formatDuration(selectedItem.duration, selectedItem.liveBroadcastContent),
                                                  description: selectedItem.description,
                                                  views: selectedItem.views,
                                                  publishedAtItem: selectedItem.publishedAt.toIso8601String(),
                                                  savedAt: DateTime.now(),
                                                );
                                                return Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    FavoriteButton(item: itemToSave),
                                                    const SizedBox(width: 12),
                                                    SaveButton(item: itemToSave),
                                                  ],
                                                );
                                              }
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ShowMoreDescription(
                                    modalTitle: AppConstants.description,
                                    description: selectedItem.description,
                                  ),
                                ],
                              ),
                            ),
                            // --- "You Might Also Like" section ---
                            _buildRelatedVideosSection(),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildRelatedVideosSection() {
    if (_isLoadingRelated) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    if (_relatedVideos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.leftMain, right: AppConstants.rightMain, top: 8),
          child: Divider(color: Theme.of(context).colorScheme.tertiaryContainer),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.leftMain, right: AppConstants.rightMain, top: 8, bottom: 4),
          child: TextOverlay(
            label: 'You Might Also Like',
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: AppConstants.fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _relatedVideos.length,
          itemBuilder: (context, index) {
            final item = _relatedVideos[index];
            return GestureDetector(
              onTap: () => _onRelatedVideoTap(item),
              child: YoutubePlaylistItemDetailsWidget(
                youTubePlaylistItemModel: item,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
