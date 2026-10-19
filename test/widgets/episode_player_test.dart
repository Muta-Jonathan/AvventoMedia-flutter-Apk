import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/download_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/controller/settings_controller.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/audio_players/episode_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';
import '../helpers/fake_push_notifications.dart';

final ep = PodcastEpisode(
  id: 'vat3',
  title: 'Victory Amidst Troubles Pt. 3',
  description: '',
  playlistMediaArtist: 'Bro. Kiiza Samuel Akiki',
  playlistMediaAlbum: 'Victory Amidst Troubles',
  publishedAt: 0,
  downloadLink: 'https://example.org/vat3.mp3',
  publicLink: 'https://example.org/vat3',
  isPublished: true,
  art: '',
  media: '',
);

void main() {
  late FakeAudioPlayer player;
  late SettingsController settings;
  late Directory dir;

  tearDown(() {
    Get.reset();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<void> pump(WidgetTester tester, {ThemeData? theme}) async {
    if (tester.view.physicalSize == const Size(2400, 1800)) {
      // Default test surface is 800x600; use a phone-height screen.
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('player_test');
    player = FakeAudioPlayer()
      ..fakeDuration = const Duration(minutes: 45)
      ..fakePosition = const Duration(minutes: 27, seconds: 4);
    settings = Get.put(
        await SettingsController.load(push: FakePushNotifications()));
    final audio = Get.put(
        AudioPlayerController(player: player, startAudioService: false));
    Get.put(PodcastEpisodeController()).setSelectedEpisode(ep);
    Get.put(LibraryController());
    Get.put(DownloadController(
        directory: () async => dir, notify: (_, {actionLabel, onAction}) {}));
    audio.currentMediaItem = MediaItem(
        id: ep.id, title: ep.title, artist: ep.playlistMediaArtist);
    await tester.pumpWidget(GetMaterialApp(
        theme: theme ?? darkTheme,
        home: const Scaffold(body: EpisodePlayer())));
    await tester.pumpAndSettle();
  }

  testWidgets('shows where it plays from, the episode and the times',
      (tester) async {
    await pump(tester);

    expect(find.text(AppConstants.playingFrom), findsOneWidget);
    expect(find.text('Victory Amidst Troubles'), findsOneWidget);
    expect(find.text('Victory Amidst Troubles Pt. 3'), findsOneWidget);
    expect(find.text('Bro. Kiiza Samuel Akiki'), findsOneWidget);
    expect(find.text('27:04'), findsOneWidget);
    expect(find.text('-17:56'), findsOneWidget);
  });

  testWidgets('tapping the time switches to the length and back, remembered',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text('-17:56'));
    await tester.pumpAndSettle();
    expect(find.text('45:00'), findsOneWidget);
    expect(settings.playerShowsTotal.value, isTrue);
    expect(find.bySemanticsLabel(AppConstants.lengthSemantics(
            const Duration(minutes: 45))),
        findsOneWidget);

    await tester.tap(find.text('45:00'));
    await tester.pumpAndSettle();
    expect(find.text('-17:56'), findsOneWidget);
    expect(find.bySemanticsLabel('17 minutes 56 seconds left'),
        findsOneWidget);
  });

  testWidgets('shuffle toggles shuffle mode', (tester) async {
    await pump(tester);

    await tester.tap(find.bySemanticsLabel(AppConstants.shuffle));
    await tester.pumpAndSettle();
    expect(player.calls, containsAllInOrder(['shuffle', 'shuffle:true']));
    expect(Get.find<AudioPlayerController>().shuffleOn.value, isTrue);

    await tester.tap(find.bySemanticsLabel(AppConstants.shuffle));
    await tester.pumpAndSettle();
    expect(player.calls.last, 'shuffle:false');
  });

  testWidgets('speed sheet sets the speed and the pill shows it',
      (tester) async {
    await pump(tester);

    await tester.tap(find.bySemanticsLabel(AppConstants.speedSemantics('1×')));
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.playbackSpeed), findsOneWidget);
    expect(find.text('0.75×'), findsOneWidget);

    await tester.tap(find.text('1.5×'));
    await tester.pumpAndSettle();
    expect(player.calls, contains('speed:1.5'));
    expect(find.bySemanticsLabel(AppConstants.speedSemantics('1.5×')),
        findsOneWidget);
  });

  testWidgets('fits a 360dp phone at 130% text in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pump(tester);
    expect(tester.takeException(), isNull);
    Get.reset();
    await pump(tester, theme: lightTheme);
    expect(tester.takeException(), isNull);
  });
}
