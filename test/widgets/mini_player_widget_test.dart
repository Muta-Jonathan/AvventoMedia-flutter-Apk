import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/widgets/audio_players/mini_player_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

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

  // No artUri: keeps CachedNetworkImage (and its plugins) out of the test.
  Future<void> pumpBar(WidgetTester tester,
      {String title = 'Episode 1', bool live = false}) async {
    controller.isLive.value = live;
    controller.currentMediaItem = MediaItem(id: title, title: title);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(height: 70, child: MiniPlayerWidget()),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('shows pause while playing and play when paused',
      (tester) async {
    await pumpBar(tester);

    player.emitState(true, ProcessingState.ready);
    await tester.pump();
    expect(find.byIcon(CupertinoIcons.pause_fill), findsOneWidget);

    player.emitState(false, ProcessingState.ready);
    await tester.pump();
    expect(find.byIcon(CupertinoIcons.play_fill), findsOneWidget);
  });

  testWidgets('shows replay after completion and restarts on tap',
      (tester) async {
    await pumpBar(tester);

    // just_audio keeps playing == true when a track completes.
    player.emitState(true, ProcessingState.completed);
    await tester.pump();
    expect(find.byIcon(CupertinoIcons.arrow_counterclockwise), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.arrow_counterclockwise));
    await tester.pump();
    expect(player.calls, ['seek:0', 'play']);
  });

  testWidgets('podcast shows a progress ring that follows position',
      (tester) async {
    player.fakeDuration = const Duration(minutes: 10);
    await pumpBar(tester);

    player.emitPosition(const Duration(minutes: 5));
    await tester.pump();

    final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator));
    expect(ring.value, closeTo(0.5, 0.001));
  });

  testWidgets('live radio shows the LIVE badge and no progress ring',
      (tester) async {
    await pumpBar(tester, live: true);

    expect(find.text('LIVE'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('title follows track changes', (tester) async {
    await pumpBar(tester, title: 'Episode 1');
    expect(find.text('Episode 1'), findsOneWidget);

    controller.currentMediaItem =
        const MediaItem(id: 'Episode 2', title: 'Episode 2');
    // The Rx update is deferred to a microtask, so it lands a frame later.
    await tester.pump();
    await tester.pump();
    expect(find.text('Episode 2'), findsOneWidget);
  });

  testWidgets('close stops playback and hides the player', (tester) async {
    await pumpBar(tester);
    controller.isPlayerActive.value = true;

    await tester.tap(find.byIcon(CupertinoIcons.xmark));
    await tester.pump();

    expect(controller.isPlayerActive.value, isFalse);
    expect(player.calls, contains('stop'));
  });
}
