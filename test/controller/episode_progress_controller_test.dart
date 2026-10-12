import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
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
}
