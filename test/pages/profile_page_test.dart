import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/controller/settings_controller.dart';
import 'package:avvento_media/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_push_notifications.dart';

void main() {
  late SettingsController settings;
  late FakePushNotifications push;

  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'AvventoMedia',
      packageName: 'tv.avventomedia.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    push = FakePushNotifications(grant: false);
    settings = Get.put(await SettingsController.load(push: push));
    Get.put(LibraryController());

    await tester.pumpWidget(const GetMaterialApp(home: ProfilePage()));
    await tester.pumpAndSettle();
  }

  Finder rowSwitch(String label) => find.descendant(
        of: find.ancestor(
            of: find.text(label), matching: find.byType(InkWell)),
        matching: find.byType(CupertinoSwitch),
      );

  testWidgets('shows the redesigned groups', (tester) async {
    await pumpPage(tester);

    expect(find.text(AppConstants.supportUs), findsOneWidget);
    expect(find.text(AppConstants.myLibrary), findsOneWidget);
    expect(find.text(AppConstants.preferences), findsOneWidget);
    expect(find.text(AppConstants.darkMode), findsOneWidget);
  });

  testWidgets('Dark Mode segments set the theme mode', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppConstants.themeOn));
    await tester.pumpAndSettle();
    expect(settings.themeMode.value, ThemeMode.dark);

    await tester.tap(find.text(AppConstants.themeOff));
    await tester.pumpAndSettle();
    expect(settings.themeMode.value, ThemeMode.light);
  });

  testWidgets('Allow Mini Player switch updates the setting', (tester) async {
    await pumpPage(tester);

    await tester.tap(rowSwitch(AppConstants.allowMiniPlayer));
    await tester.pumpAndSettle();
    expect(settings.miniPlayerEnabled.value, isFalse);
  });

  testWidgets('denied notification permission keeps the switch off',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(rowSwitch(AppConstants.allowNotifications));
    await tester.pumpAndSettle();
    expect(settings.notificationsEnabled.value, isFalse);
    expect(find.text(AppConstants.notificationsDenied), findsOneWidget);

    // Let the snackbar timer finish.
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('legal links are at the bottom', (tester) async {
    await pumpPage(tester);

    await tester.scrollUntilVisible(
        find.text(AppConstants.privacyPolicy), 300);
    expect(find.text(AppConstants.termsOfService), findsOneWidget);
    expect(find.text(AppConstants.privacyPolicy), findsOneWidget);
  });
}
