import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

void main() {
  late FakeAudioPlayer player;
  late AudioPlayerController audio;
  late EpisodeProgressController progress;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    player = FakeAudioPlayer()..fakeDuration = const Duration(minutes: 40);
    audio = Get.put(
        AudioPlayerController(player: player, startAudioService: false));
    progress = Get.put(EpisodeProgressController());
    await progress.ready;
    audio.currentMediaItem = MediaItem(id: 'ep1', title: 'Episode 1');
    await flush();
  });

  tearDown(Get.reset);

  test('records position and length, and resumes from them', () async {
    player.emitPosition(const Duration(minutes: 10));
    await flush();

    final p = progress.of('ep1');
    expect(p.position, const Duration(minutes: 10));
    expect(p.duration, const Duration(minutes: 40));
    expect(p.fraction, 0.25);
    expect(progress.resumePosition('ep1'), const Duration(minutes: 10));
  });

  test('is saved and survives a restart', () async {
    player.emitPosition(const Duration(minutes: 10));
    await flush();
    await flush();

    Get.delete<EpisodeProgressController>();
    final reloaded = Get.put(EpisodeProgressController());
    await reloaded.ready;
    expect(reloaded.of('ep1').position, const Duration(minutes: 10));
  });

  test('finishing marks played and starts over next time', () async {
    player.emitPosition(const Duration(minutes: 20));
    await flush();
    player.emitState(false, ProcessingState.completed);
    await flush();

    expect(progress.isPlayed('ep1'), isTrue);
    expect(progress.resumePosition('ep1'), isNull);
  });

  test('the last seconds count as played', () async {
    player.emitPosition(const Duration(minutes: 39, seconds: 50));
    await flush();
    expect(progress.isPlayed('ep1'), isTrue);
  });

  test('live radio is ignored', () async {
    audio.isLive.value = true;
    player.emitPosition(const Duration(minutes: 10));
    await flush();
    expect(progress.progress, isEmpty);
  });

  test('mark played / unplayed', () {
    progress.setPlayed('ep2', true);
    expect(progress.isPlayed('ep2'), isTrue);
    progress.setPlayed('ep2', false);
    expect(progress.isPlayed('ep2'), isFalse);
  });

  group('continue listening', () {
    PodcastEpisode episode(String id) => PodcastEpisode(
        id: id,
        title: 'Title $id',
        description: '',
        playlistMediaArtist: '',
        playlistMediaAlbum: '',
        publishedAt: 1,
        downloadLink: 'https://x/$id.mp3',
        publicLink: '',
        isPublished: true,
        art: '',
        media: '');

    setUp(() {
      Get.put(PodcastEpisodeController())
          .setQueue([episode('ep1'), episode('ep2')], showTitle: 'Genesis');
    });

    List<String> ids() =>
        [for (final r in progress.continueListening) r.episode.id];

    test('lists part-listened episodes with their show', () async {
      player.emitPosition(const Duration(minutes: 10));
      await flush();

      expect(ids(), ['ep1']);
      expect(progress.continueListening.single.showTitle, 'Genesis');
    });

    test('drops episodes you finish or barely started', () async {
      player.emitPosition(const Duration(seconds: 4));
      await flush();
      expect(ids(), isEmpty);

      player.emitPosition(const Duration(minutes: 10));
      await flush();
      player.emitState(false, ProcessingState.completed);
      await flush();
      expect(ids(), isEmpty);
    });

    test('most recent first, and kept across a restart', () async {
      player.emitPosition(const Duration(minutes: 10));
      await flush();
      audio.currentMediaItem = MediaItem(id: 'ep2', title: 'Episode 2');
      await flush();
      player.emitPosition(const Duration(minutes: 12));
      await flush();
      await flush();
      expect(ids(), ['ep2', 'ep1']);

      Get.delete<EpisodeProgressController>();
      final reloaded = Get.put(EpisodeProgressController());
      await reloaded.ready;
      expect([for (final r in reloaded.continueListening) r.episode.id],
          ['ep2', 'ep1']);
    });
  });
}
