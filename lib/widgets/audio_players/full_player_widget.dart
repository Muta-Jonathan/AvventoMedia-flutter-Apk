import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/models/musicplayermodels/music_player_position.dart';
import 'package:avvento_media/widgets/audio_players/controls.dart';
import 'package:avvento_media/widgets/audio_players/speed_control.dart';
import 'package:avvento_media/widgets/common/favorite_button.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/common/save_button.dart';
import 'package:avvento_media/widgets/providers/radio_station_provider.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../../controller/podcast_episode_controller.dart';
import '../../models/saved_item_model.dart';

/// The full-screen inline player that is rendered inside the expanded PlayerPanel.
/// This replaces the route-based OnlineRadioPage / PodcastPage when the panel is expanded.
class FullPlayerWidget extends StatefulWidget {
  const FullPlayerWidget({super.key});

  @override
  State<FullPlayerWidget> createState() => _FullPlayerWidgetState();
}

class _FullPlayerWidgetState extends State<FullPlayerWidget> {
  late AudioPlayerController _controller;

  Stream<MusicPlayerPosition> get _positionStream =>
      rx.Rx.combineLatest3<Duration, Duration, Duration?, MusicPlayerPosition>(
        _controller.audioPlayer.positionStream,
        _controller.audioPlayer.bufferedPositionStream,
        _controller.audioPlayer.durationStream,
        (position, bufferedPosition, duration) => MusicPlayerPosition(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
          _controller.currentMediaItem!,
        ),
      );

  bool _radioInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AudioPlayerController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive = _controller.isLive.value;
      return isLive ? _buildRadioPlayer(context) : _buildPodcastPlayer(context);
    });
  }

  // ---------------------------------------------------------------------------
  // RADIO PLAYER
  // ---------------------------------------------------------------------------
  Widget _buildRadioPlayer(BuildContext context) {
    return Consumer<RadioStationProvider>(
      builder: (context, radioProvider, _) {
        if (radioProvider.radioStation == null) {
          return const Center(child: LoadingWidget());
        }

        // Initialize audio source once a usable stream URL arrives
        if (!_radioInitialized) {
          if (radioProvider.radioStation!.streamUrl.isEmpty) {
            return const Center(child: LoadingWidget());
          }
          _radioInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final station = radioProvider.radioStation!;
            final item = MediaItem(
              id: station.id.toString(),
              title: station.nowPlayingTitle,
              artist: station.artist,
              artUri: Uri.parse(station.imageUrl),
              duration: Utils.parseDuration(station.duration),
            );
            if (!_controller.audioPlayer.playerState.playing) {
              await _controller.setAudioSource(station.streamUrl, item);
            }
          });
        } else {
          _controller.updateRadioProgram(
            radioProvider.radioStation!.nowPlayingTitle,
            radioProvider.radioStation!.artist,
            radioProvider.radioStation!.imageUrl,
            Utils.parseDuration(radioProvider.radioStation!.duration),
            Utils.parseDuration(radioProvider.radioStation!.elapsed),
          );
        }

        final station = radioProvider.radioStation!;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final paddingWidth = screenWidth * 0.05;
        final paddingTop = screenHeight * 0.02;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Header row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.chevron_down),
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: () => _controller.panelController.collapse(),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextOverlay(
                              label: AppConstants.nowPlaying,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: AppConstants.fontSize18,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(CupertinoIcons.share,
                            color: Theme.of(context).colorScheme.onPrimary),
                        onPressed: () => Utils.share(
                            '${AppConstants.shareStream}, \n ${AppConstants.webRadioUrl}'),
                      ),
                    ],
                  ),
                ),
                // Artwork
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: station.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (_, __) => const Center(child: LoadingWidget()),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.error,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // Track info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextOverlay(
                        label: station.nowPlayingTitle,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: AppConstants.fontSize20,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextOverlay(
                          label: station.artist,
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 14,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar (non-interactive for live radio)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: paddingWidth, vertical: paddingTop),
                  child: IgnorePointer(
                    child: ProgressBar(
                      baseBarColor: Colors.grey[600],
                      bufferedBarColor: Colors.grey,
                      thumbColor: Colors.transparent,
                      thumbGlowRadius: 0,
                      thumbRadius: 0,
                      progressBarColor: Colors.redAccent,
                      buffered: Utils.parseDuration(station.elapsed),
                      progress: Utils.parseDuration(station.elapsed),
                      total: Utils.parseDuration(station.duration),
                      timeLabelTextStyle:
                          TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
                Controls(audioPlayerController: _controller),
                SizedBox(height: screenHeight * 0.08),
                TextOverlay(
                  label: AppConstants.avventoSlogan,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PODCAST PLAYER
  // ---------------------------------------------------------------------------
  Widget _buildPodcastPlayer(BuildContext context) {
    final episodeController = Get.find<PodcastEpisodeController>();
    final selectedEpisode = episodeController.selectedEpisode.value;

    if (selectedEpisode == null || _controller.currentMediaItem == null) {
      return const Center(child: LoadingWidget());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingWidth = screenWidth * 0.05;
    final paddingTop = screenHeight * 0.02;
    final publishedDate = Jiffy.parse(Utils.formatTimestamp(
            timestamp: selectedEpisode.publishedAt,
            format: 'yyyy-MM-dd HH:mm:ss'))
        .fromNow();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingWidth),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.chevron_down),
                    color: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () => _controller.panelController.collapse(),
                  ),
                  Expanded(
                    child: Center(
                      child: TextOverlay(
                        label: AppConstants.podcasts,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: AppConstants.fontSize18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.share,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () => Utils.share(
                        'Come Join Me, Listen to the wonderful Podcast on AvventoMedia 💫, \n ${selectedEpisode.publicLink}'),
                  ),
                ],
              ),
            ),
            // Artwork
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.02),
              child: Container(
                width: screenWidth * 0.85,
                height: screenHeight * 0.38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: selectedEpisode.art,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (_, __) => const Center(child: LoadingWidget()),
                    errorWidget: (_, __, ___) =>
                        Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Track info + progress + controls
            StreamBuilder<MusicPlayerPosition>(
              stream: _positionStream,
              builder: (_, snapshot) {
                final positionData = snapshot.data;
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextOverlay(
                            label: _controller.currentMediaItem!.title,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: AppConstants.fontSize20,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextOverlay(
                              label: _controller.currentMediaItem?.artist ?? '',
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontSize: 16,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextOverlay(
                            label: 'Published $publishedDate',
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: paddingWidth, right: paddingWidth, top: paddingTop),
                      child: ProgressBar(
                        baseBarColor: Colors.grey[600],
                        bufferedBarColor: Colors.grey,
                        thumbColor: Colors.redAccent,
                        thumbRadius: 5,
                        progressBarColor: Colors.redAccent,
                        progress: positionData?.position ?? Duration.zero,
                        buffered: positionData?.bufferedPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero,
                        timeLabelTextStyle:
                            TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        onSeek: _controller.audioPlayer.seek,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Controls(audioPlayerController: _controller),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpeedControl(audioPlayerController: _controller),
                        const SizedBox(width: 20),
                        StreamBuilder<Duration?>(
                          stream: _controller.audioPlayer.durationStream,
                          builder: (context, snapshot) {
                            final duration =
                                snapshot.data ?? _controller.audioPlayer.duration;
                            final itemToSave = SavedItem(
                              id: selectedEpisode.id,
                              type: 'podcast_episode',
                              title: selectedEpisode.title,
                              thumbnailUrl: selectedEpisode.art,
                              groupId: selectedEpisode.playlistMediaAlbum,
                              groupTitle: selectedEpisode.playlistMediaAlbum,
                              url: selectedEpisode.downloadLink,
                              duration: duration != null
                                  ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
                                  : null,
                              description: selectedEpisode.description,
                              publishedAtItem: DateTime.fromMillisecondsSinceEpoch(
                                      selectedEpisode.publishedAt * 1000)
                                  .toIso8601String(),
                              savedAt: DateTime.now(),
                            );
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FavoriteButton(item: itemToSave),
                                const SizedBox(width: 20),
                                SaveButton(item: itemToSave),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    TextOverlay(
                      label: AppConstants.avventoSlogan,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
