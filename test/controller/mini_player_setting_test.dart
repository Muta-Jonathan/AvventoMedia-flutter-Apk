import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/settings_controller.dart';
import 'package:avvento_media/widgets/audio_players/player_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';
import '../helpers/fake_push_notifications.dart';

/// "Allow Mini Player" off: playback opens the full player, collapsing it
/// hides the player (audio keeps going), and the mini bar never shows.
void main() {
  late SettingsController settings;
  late AudioPlayerController audio;

  tearDown(Get.reset);

  /// Created inside each test body: futures made in setUp live outside the
  /// test's fake-async zone and never complete there.
  Future<void> pumpPanel(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    settings =
        Get.put(await SettingsController.load(push: FakePushNotifications()));
    await settings.setMiniPlayerEnabled(false);
    audio = Get.put(AudioPlayerController(
        player: FakeAudioPlayer(), startAudioService: false));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerPanel(
            controller: audio.panelController,
            minHeight: 70,
            maxHeight: 500,
            onChanged: audio.onPanelPercentageChanged,
            builder: (_, __) => const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Future<void> startPlayback() => audio.setAudioSource(
      'https://example.com/a.mp3', const MediaItem(id: 'a', title: 'A'));

  testWidgets('starting playback opens the full player', (tester) async {
    await pumpPanel(tester);
    await startPlayback();
    await tester.pumpAndSettle();

    expect(audio.panelPercentage.value, 1.0);
    expect(audio.isMiniPlayerVisible.value, isTrue);
  });

  testWidgets('collapsing hides the player instead of leaving a mini bar',
      (tester) async {
    await pumpPanel(tester);
    await startPlayback();
    await tester.pumpAndSettle();

    audio.collapsePlayer();
    await tester.pumpAndSettle();

    expect(audio.isMiniPlayerVisible.value, isFalse);
    expect(audio.isPlayerActive.value, isTrue, reason: 'audio keeps playing');
  });

  testWidgets('switching tabs does not bring the mini bar back',
      (tester) async {
    await pumpPanel(tester);
    await startPlayback();
    await tester.pumpAndSettle();
    audio.collapsePlayer();
    await tester.pumpAndSettle();

    audio.showMiniPlayer();
    await tester.pump();
    expect(audio.isMiniPlayerVisible.value, isFalse);
  });

  testWidgets('turning the setting back on shows the mini bar', (tester) async {
    await pumpPanel(tester);
    await startPlayback();
    await tester.pumpAndSettle();
    audio.collapsePlayer();
    await tester.pumpAndSettle();

    await settings.setMiniPlayerEnabled(true);
    expect(audio.isMiniPlayerVisible.value, isTrue);
  });
}
