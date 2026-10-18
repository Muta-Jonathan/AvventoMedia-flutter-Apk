import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/models/radiomodel/radio_station_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fake_audio_player.dart';

void main() {
  late FakeAudioPlayer player;
  late AudioPlayerController controller;

  setUp(() {
    player = FakeAudioPlayer();
    controller = Get.put(
        AudioPlayerController(player: player, startAudioService: false));
  });

  tearDown(Get.reset);

  test('pause stops live radio but pauses podcasts', () async {
    controller.isLive.value = true;
    await controller.pause();
    controller.isLive.value = false;
    await controller.pause();

    expect(player.calls, ['stop', 'pause']);
  });

  test('replay seeks to the start and plays', () async {
    await controller.replay();
    expect(player.calls, ['seek:0', 'play']);
  });

  test('currentMediaItem reads update at once, Rx after a microtask', () async {
    const item = MediaItem(id: '1', title: 'Episode 1');
    controller.currentMediaItem = item;

    expect(controller.currentMediaItem, item);
    expect(controller.currentMediaItemRx.value, isNull);

    await Future<void>.delayed(Duration.zero);
    expect(controller.currentMediaItemRx.value, item);
  });

  test('a new song with the same id reaches the Rx (live radio)', () async {
    controller.currentMediaItem = const MediaItem(id: 'radio', title: 'Song A');
    await Future<void>.delayed(Duration.zero);
    // MediaItem == compares ids only; the new title must still show.
    controller.currentMediaItem = const MediaItem(id: 'radio', title: 'Song B');
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentMediaItemRx.value?.title, 'Song B');
  });

  RadioStation station(String title) => RadioStation(
        id: 1,
        artist: 'Heritage Singers',
        imageUrl: 'https://example.com/art.jpg',
        nowPlayingTitle: title,
        streamUrl: 'https://example.com/stream',
        duration: 240,
        elapsed: 10,
        nextProgram: '',
      );

  test('radio song changes update the player from any screen', () async {
    controller.isLive.value = true;
    await controller.setAudioSource(
        'https://example.com/stream',
        MediaItem(
            id: '1',
            title: 'Song A',
            artist: 'Heritage Singers',
            artUri: Uri.parse('https://example.com/art.jpg')));
    await Future<void>.delayed(Duration.zero);

    controller.syncRadioStation(station('It Is Well With My Soul'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentMediaItem?.title, 'It Is Well With My Soul');
    expect(controller.currentMediaItemRx.value?.title,
        'It Is Well With My Soul');
  });

  test('radio updates are ignored while a podcast plays', () async {
    controller.isLive.value = false;
    await controller.setAudioSource(
        'https://example.com/ep.mp3', const MediaItem(id: 'ep', title: 'Ep 1'));

    controller.syncRadioStation(station('Live song'));
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentMediaItem?.title, 'Ep 1');
  });

  test('setAudioSource works without a ready AudioService', () async {
    // Regression: opening radio right after launch used audioHandler before
    // AudioService.init finished (LateInitializationError).
    const item = MediaItem(id: 'radio', title: 'Live');
    await controller.setAudioSource('https://example.com/stream', item);

    expect(controller.isPlayerActive.value, isTrue);
    expect(controller.currentMediaItem, item);
    expect(player.calls, ['setAudioSource']);
  });

  test('an interrupted load (e.g. closed while loading) is not an error',
      () async {
    player.interruptNextLoad = true;
    await controller.setAudioSource(
        'https://example.com/stream', const MediaItem(id: 'r', title: 'Live'));

    expect(player.calls, ['setAudioSource']);
  });

  testWidgets('back collapses the expanded player instead of popping',
      (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      home: const Scaffold(body: Text('home')),
      getPages: [
        GetPage(name: '/', page: () => const Scaffold(body: Text('home'))),
        GetPage(name: '/next', page: () => const Scaffold(body: Text('next'))),
      ],
    ));
    Get.toNamed('/next');
    await tester.pumpAndSettle();

    controller.onPanelPercentageChanged(1.0);
    await tester.pump();

    // Back is consumed by the player: the page stays.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('next'), findsOneWidget);

    // Collapsed: back pops the page as usual.
    controller.onPanelPercentageChanged(0.0);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('next'), findsNothing);
  });
}
