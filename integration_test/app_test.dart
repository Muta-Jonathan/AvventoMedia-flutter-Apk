import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/nav_bar_controller.dart';
import 'package:avvento_media/main.dart' as app;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      if (DateTime.now().isAfter(deadline)) {
        debugPrint('E2E timed out: $reason');
        fail('Timed out: $reason');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// A bottom navigation tab by its label (Listen is also a page title).
  Finder navTab(String label) => find.descendant(
      of: find.byType(BottomNavigationBar), matching: find.text(label));

  /// Upgrader may show an update dialog depending on the store version, and
  /// late on a slow emulator.
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
    await pumpUntil(
        tester, () => navTab(AppConstants.navListen).evaluate().isNotEmpty,
        reason: 'bottom navigation');
    await dismissUpdateDialog(tester);
    final audio = Get.find<AudioPlayerController>();

    // Tabs
    for (final tab in [
      AppConstants.navSearch,
      AppConstants.navMore,
      AppConstants.navWatch,
      AppConstants.navListen,
    ]) {
      await tester.tap(navTab(tab));
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Record what the app tells Android about Back (predictive back): if
    // it says "can't handle", Android closes the app on Back.
    bool? frameworkHandlesBack;
    final messenger = tester.binding.defaultBinaryMessenger;
    const platform = SystemChannels.platform;
    messenger.setMockMessageHandler(platform.name, (data) {
      final call = platform.codec.decodeMethodCall(data);
      if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
        frameworkHandlesBack = call.arguments as bool;
      }
      // Pass every call on so the app behaves as usual.
      return messenger.delegate.send(platform.name, data);
    });
    addTearDown(() => messenger.setMockMessageHandler(platform.name, null));

    // The live card on Listen opens the full radio player
    await pumpUntil(
        tester, () => find.text(AppConstants.liveBadge).evaluate().isNotEmpty,
        reason: 'live card on Listen');
    await tester.tap(find.text(AppConstants.liveBadge).first);
    await pumpUntil(tester, () => audio.panelPercentage.value > 0.95,
        reason: 'full player expands');
    await pumpUntil(tester, () => audio.currentMediaItem != null,
        reason: 'radio station loads');

    // Back collapses the player and keeps the app on the Listen tab
    await dismissUpdateDialog(tester);
    await tester.binding.handlePopRoute();
    await pumpUntil(tester, () => audio.panelPercentage.value < 0.05,
        reason: 'player collapses on back');
    // The BottomNav is rebuilt a frame after panelPercentage changes.
    await pumpUntil(
        tester, () => find.byType(BottomNavigationBar).evaluate().isNotEmpty,
        reason: 'bottom navigation returns');
    await pumpUntil(tester,
        () => find.text(AppConstants.liveSubtitle).evaluate().isNotEmpty,
        reason: 'mini bar shows Live');

    // The full player's own Navigator must not tell Android "can't pop".
    expect(frameworkHandlesBack, isNot(false),
        reason: 'Back would close the app');

    // Close hides the mini bar
    await tester.tap(find.byIcon(CupertinoIcons.xmark));
    await pumpUntil(tester, () => !audio.isPlayerActive.value,
        reason: 'close hides the player');

    // Back on another tab goes Home; on Home it asks to press again.
    final nav = Get.find<NavBarController>();
    expect(nav.tabIndex, 1);
    await dismissUpdateDialog(tester);
    await tester.binding.handlePopRoute();
    await pumpUntil(tester, () => nav.tabIndex == 0, reason: 'back goes Home');
    await dismissUpdateDialog(tester);
    await tester.binding.handlePopRoute();
    await pumpUntil(
        tester, () => find.text(AppConstants.exitApp).evaluate().isNotEmpty,
        reason: 'exit hint on Home');
    expect(frameworkHandlesBack, isNot(false));
  });
}
