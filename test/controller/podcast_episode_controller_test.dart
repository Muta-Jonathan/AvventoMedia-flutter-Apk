import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fake_audio_player.dart';

PodcastEpisode episode(String id) => PodcastEpisode(
      id: id,
      title: 'Episode $id',
      description: '',
      playlistMediaArtist: '',
      playlistMediaAlbum: '',
      publishedAt: 0,
      downloadLink: '',
      publicLink: '',
      isPublished: true,
      art: '',
      media: '',
    );

void main() {
  late AudioPlayerController audio;
  late PodcastEpisodeController episodes;

  setUp(() {
    audio = Get.put(AudioPlayerController(
        player: FakeAudioPlayer(), startAudioService: false));
    episodes = Get.put(PodcastEpisodeController());
  });

  tearDown(Get.reset);

  Future<void> playTrack(String id) async {
    audio.currentMediaItem = MediaItem(id: id, title: id);
    await Future<void>.delayed(Duration.zero);
  }

  test('selectedEpisode follows next / auto-advance within the queue',
      () async {
    episodes.setQueue([episode('a'), episode('b')]);
    episodes.setSelectedEpisode(episode('a'));

    await playTrack('b');
    expect(episodes.selectedEpisode.value?.id, 'b');
  });

  test('tracks outside the queue (e.g. live radio) are ignored', () async {
    episodes.setQueue([episode('a')]);
    episodes.setSelectedEpisode(episode('a'));

    await playTrack('radio');
    expect(episodes.selectedEpisode.value?.id, 'a');
  });
}
