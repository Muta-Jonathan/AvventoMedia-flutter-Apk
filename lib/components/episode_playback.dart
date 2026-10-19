import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../apis/azuracast_api.dart';
import '../controller/audio_player_controller.dart';
import '../controller/download_controller.dart';
import '../controller/episode_progress_controller.dart';
import '../controller/podcast_episode_controller.dart';
import '../models/radiomodel/podcast_episode_model.dart';

/// Starts podcast episodes on the shared player, shared by the episode feed
/// and Downloads.
class EpisodePlayback {
  static AudioPlayerController get _audio => Get.find<AudioPlayerController>();

  static T? _maybe<T>() => Get.isRegistered<T>() ? Get.find<T>() : null;

  /// Whether [id] is the loaded episode.
  static bool isCurrent(String id) => _audio.currentMediaItem?.id == id;

  /// Plays `queue[index]` with [queue] as the up-next list: downloaded
  /// episodes play from the device, and a part-played one resumes.
  /// [expand] opens the full player.
  static Future<void> play(List<PodcastEpisode> queue, int index,
      {bool expand = false}) async {
    final audio = _audio;
    final downloads = _maybe<DownloadController>();
    final episode = queue[index];

    Get.find<PodcastEpisodeController>()
      ..setSelectedEpisode(episode)
      ..setQueue(queue);
    audio.isLive.value = false;

    final sources = [
      for (final ep in queue) _source(ep, downloads?.localPath(ep.id)),
    ];
    if (expand) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => audio.panelController.expand());
    }
    await audio.setAudioPlaylist(sources, index,
        initialPosition:
            _maybe<EpisodeProgressController>()?.resumePosition(episode.id));
    audio.play();
  }

  /// Play/pause when [queue]`[index]` is loaded, otherwise start it.
  static void toggle(List<PodcastEpisode> queue, int index) {
    final audio = _audio;
    if (!isCurrent(queue[index].id)) {
      play(queue, index);
    } else if (audio.audioPlayer.processingState == ProcessingState.completed) {
      audio.replay();
    } else {
      audio.audioPlayer.playing ? audio.pause() : audio.play();
    }
  }

  /// Opens the full player on `queue[index]`, starting it if needed.
  static void open(List<PodcastEpisode> queue, int index) {
    if (isCurrent(queue[index].id)) {
      _audio.panelController.expand();
    } else {
      play(queue, index, expand: true);
    }
  }

  static AudioSource _source(PodcastEpisode ep, String? localPath) {
    final tag = MediaItem(
      id: ep.id,
      title: ep.title,
      artist: ep.playlistMediaArtist,
      artUri: Uri.parse(ep.art),
    );
    return localPath != null
        ? AudioSource.file(localPath, tag: tag)
        : AudioSource.uri(Uri.parse(ep.downloadLink),
            headers: AzuraCastAPI.mediaHeaders(ep.downloadLink), tag: tag);
  }
}
