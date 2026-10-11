import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/main.dart' as app;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

/// Real-device smoke tests. They hit live APIs (AzuraCast, YouTube), so they
/// need network access.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps until [condition] holds. pumpAndSettle can't be used: loading
  /// spinners and marquees never settle.
  Future<void> pumpUntil(
    WidgetTester tester,
    bool Function() condition, {
    String reason = '',
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) fail('Timed out: $reason');
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Upgrader may show an update dialog depending on the store version.
  Future<void> dismissUpdateDialog(WidgetTester tester) async {
    final later = find.textContaining(RegExp('later', caseSensitive: false));
    if (later.evaluate().isNotEmpty) {
      await tester.tap(later.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  // One test: main() initialises Firebase and GetX bindings, so the app is
  // launched once and the flows run in sequence.
  testWidgets('app smoke test: tabs and live radio mini player',
      (tester) async {
    await app.main();
    await pumpUntil(tester, () => find.text('Audio').evaluate().isNotEmpty,
        reason: 'bottom navigation');
    await dismissUpdateDialog(tester);
    final audio = Get.find<AudioPlayerController>();

    // Tabs
    for (final tab in ['Search', 'More', 'Videos', 'Audio']) {
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Live radio opens the full player
    await tester
        .tap(find.byIcon(CupertinoIcons.antenna_radiowaves_left_right).first);
    await pumpUntil(tester, () => audio.panelPercentage.value > 0.95,
        reason: 'full player expands');
    await pumpUntil(tester, () => audio.currentMediaItem != null,
        reason: 'radio station loads');

    // Back collapses the player and keeps the app on the Audio tab
    await tester.binding.handlePopRoute();
    await pumpUntil(tester, () => audio.panelPercentage.value < 0.05,
        reason: 'player collapses on back');
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('LIVE'), findsWidgets);

    // Close hides the mini bar
    await tester.tap(find.byIcon(CupertinoIcons.xmark));
    await pumpUntil(tester, () => !audio.isPlayerActive.value,
        reason: 'close hides the player');
  });
}
