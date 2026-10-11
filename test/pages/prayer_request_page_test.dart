import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/models/sendemail/send_email.dart';
import 'package:avvento_media/pages/prayer_request_page.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late List<SendEmail> sent;

  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester, {bool succeed = true}) async {
    sent = [];
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GetMaterialApp(
      home: PrayerRequestPage(sender: (request) async {
        sent.add(request);
        return succeed;
      }),
    ));
    await tester.pumpAndSettle();
  }

  Finder field(String hint) => find.widgetWithText(TextField, hint);

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(field(AppConstants.prayerHintName), 'Jane Doe');
    await tester.enterText(field(AppConstants.prayerHintPhone), '772123456');
    await tester.enterText(
        field(AppConstants.prayerHintEmail), 'jane@example.com');
    await tester.tap(find.text('Family'));
    await tester.enterText(
        field(AppConstants.prayerHintMessage), 'Please pray for us.');
    await tester.pump();
  }

  Future<void> tapSend(WidgetTester tester) async {
    await tester.tap(find.text(AppConstants.prayerSend));
    await tester.pumpAndSettle();
  }

  testWidgets('errors appear only after Send, and nothing is sent',
      (tester) async {
    await pumpPage(tester);
    expect(find.textContaining(AppConstants.prayerErrorName), findsNothing);

    await tapSend(tester);
    expect(find.textContaining(AppConstants.prayerErrorName), findsOneWidget);
    expect(find.textContaining(AppConstants.prayerErrorMessage),
        findsOneWidget);
    expect(sent, isEmpty);
  });

  testWidgets('a topic chip fills Pray for; tapping again clears it',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Health'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Health'), findsOneWidget);

    await tester.tap(find.text('Health').first);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Health'), findsNothing);
  });

  testWidgets('message shows a character count', (tester) async {
    await pumpPage(tester);
    await tester.enterText(field(AppConstants.prayerHintMessage), 'Amen');
    await tester.pump();
    expect(find.text('4 / ${AppConstants.prayerMaxLength}'), findsOneWidget);
  });

  testWidgets('a valid request is sent and shows the success view',
      (tester) async {
    await pumpPage(tester);
    await fillValid(tester);
    await tapSend(tester);

    expect(sent.single.name, 'Jane Doe');
    expect(sent.single.email, 'jane@example.com');
    expect(sent.single.subject, 'Family');
    expect(sent.single.phoneNumber, endsWith('772123456'));
    expect(find.text(AppConstants.prayerSent), findsOneWidget);
    expect(find.text(AppConstants.prayerSentMessage('Jane')), findsOneWidget);

    await tester.tap(find.text(AppConstants.prayerSendAnother));
    await tester.pumpAndSettle();
    expect(field(AppConstants.prayerHintName), findsOneWidget);
    expect(find.text('Jane Doe'), findsNothing);
  });

  testWidgets('a failed send keeps the form and shows an error',
      (tester) async {
    await pumpPage(tester, succeed: false);
    await fillValid(tester);
    await tapSend(tester);

    expect(find.text(AppConstants.prayerSent), findsNothing);
    expect(find.text(AppConstants.prayerRequestError), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('country picker is readable in dark mode', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GetMaterialApp(
      theme: darkTheme,
      home: PrayerRequestPage(sender: (_) async => true),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+256'));
    await tester.pumpAndSettle();

    final background = darkTheme.colorScheme.surface;
    final countryName = tester.widget<Text>(find.text('Afghanistan'));
    expect(countryName.style?.color, isNot(background));
    expect(countryName.style?.color, Colors.white);

    // The search box text has no style hook; it follows the Theme override.
    final search = tester.widget<EditableText>(find.descendant(
        of: find.byType(Dialog), matching: find.byType(EditableText)));
    expect(search.style.color, isNot(background));
  });
}
