import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';

import '../../../controller/audio_player_controller.dart';
import '../../../controller/podcast_controller.dart';
import '../../../controller/podcast_episode_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../../common/loading_widget.dart';
import '../../providers/radio_podcast_provider.dart';
import 'episode_list_details_screen.dart';

class EpisodeListScreen extends StatefulWidget {
  const EpisodeListScreen({super.key});

  @override
  State<EpisodeListScreen> createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeListScreen> {
  final podcastEpisodeController = Get.put(PodcastEpisodeController());
  final PodcastController podcastController = Get.find<PodcastController>();
  final AudioPlayerController audioPlayerController =
      Get.find<AudioPlayerController>();

  @override
  void initState() {
    super.initState();
    Provider.of<RadioPodcastProvider>(context, listen: false)
        .fetchAllEpisodes(podcastController.selectedEpisode.value!.episodesLink);
  }

  @override
  Widget build(BuildContext context) {
    return buildGridView(context);
  }

  Widget buildGridView(BuildContext context) {
    return Consumer<RadioPodcastProvider>(
      builder: (context, podcastProvider, child) {
        if (podcastProvider.podcastEpisodes.isEmpty) {
          return const LoadingWidget();
        } else {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: podcastProvider.podcastEpisodes.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                return buildEpisodeCard(
                    podcastProvider.podcastEpisodes[index], podcastProvider);
              },
            ),
          );
        }
      },
    );
  }

  /// Builds the audio sources list and returns the initial index for [episode].
  (List<AudioSource>, int) _buildSources(
      RadioPodcastProvider provider, PodcastEpisode episode) {
    // Keep natural API order (newest first) — standard podcast app behaviour.
    // Next = episode below in the list (older), Prev = episode above (newer).
    final episodes = provider.podcastEpisodes;
    final initialIndex = episodes.indexOf(episode);
    final sources = episodes
        .map((ep) => AudioSource.uri(
              Uri.parse(ep.downloadLink),
              tag: MediaItem(
                id: ep.id,
                title: ep.title,
                artist: ep.playlistMediaArtist,
                artUri: Uri.parse(ep.art),
              ),
            ))
        .toList();
    return (sources, initialIndex >= 0 ? initialIndex : 0);
  }

  /// Start playing [episode] (or play/pause if already selected).
  void _playEpisode(
      PodcastEpisode episode, RadioPodcastProvider provider) {
    final isSelected =
        audioPlayerController.currentMediaItem?.id == episode.id;

    if (isSelected) {
      // Toggle play/pause for the current episode
      if (audioPlayerController.audioPlayer.playing) {
        audioPlayerController.pause();
      } else {
        audioPlayerController.play();
      }
      return;
    }

    podcastEpisodeController.setSelectedEpisode(episode);
    audioPlayerController.isLive.value = false;

    final (sources, index) = _buildSources(provider, episode);
    podcastEpisodeController.setQueue(provider.podcastEpisodes);
    audioPlayerController.setAudioPlaylist(sources, index);
    // No panel expansion — just starts playing in the mini bar
  }

  /// Start playing [episode] AND expand the full player panel.
  void _playAndExpand(
      PodcastEpisode episode, RadioPodcastProvider provider) {
    final isSelected =
        audioPlayerController.currentMediaItem?.id == episode.id;

    podcastEpisodeController.setSelectedEpisode(episode);
    audioPlayerController.isLive.value = false;

    if (!isSelected) {
      final (sources, index) = _buildSources(provider, episode);
      podcastEpisodeController.setQueue(provider.podcastEpisodes);
      audioPlayerController.setAudioPlaylist(sources, index);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioPlayerController.miniplayerController
          .animateToHeight(state: PanelState.MAX);
    });
  }

  Widget buildEpisodeCard(
      PodcastEpisode episode, RadioPodcastProvider provider) {
    return GestureDetector(
      // Tap card body → play + open full player
      onTap: () => _playAndExpand(episode, provider),
      child: EpisodeListDetailsWidget(
        episode: episode,
        audioPlayerController: audioPlayerController,
        // Play button callback → play/pause only, no panel expansion
        onPlayTap: () => _playEpisode(episode, provider),
      ),
    );
  }
}