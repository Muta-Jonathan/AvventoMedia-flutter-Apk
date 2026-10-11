import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
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
