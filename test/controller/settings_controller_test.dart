import 'package:avvento_media/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_push_notifications.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('defaults: follow the system theme, mini player on',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await SettingsController.load(push: FakePushNotifications());

    expect(settings.themeMode.value, ThemeMode.system);
    expect(settings.miniPlayerEnabled.value, isTrue);
  });

  testWidgets('theme and mini player choices persist across launches',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
    final settings = await SettingsController.load(push: FakePushNotifications());

    await settings.setThemeMode(ThemeMode.dark);
    await settings.setMiniPlayerEnabled(false);
    await tester.pump();
    // The running app switched theme.
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);

    final reloaded =
        await SettingsController.load(push: FakePushNotifications());
    expect(reloaded.themeMode.value, ThemeMode.dark);
    expect(reloaded.miniPlayerEnabled.value, isFalse);
  });

  testWidgets('notifications follow the permission result', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final push = FakePushNotifications(grant: false);
    final settings = await SettingsController.load(push: push);

    expect(await settings.setNotificationsEnabled(true), isFalse);
    expect(settings.notificationsEnabled.value, isFalse);

    push.grant = true;
    expect(await settings.setNotificationsEnabled(true), isTrue);
    expect(push.enabled, isTrue);

    await settings.setNotificationsEnabled(false);
    expect(push.enabled, isFalse);
    expect(settings.notificationsEnabled.value, isFalse);
  });
}
