import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/common/media_list_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/a11y.dart';
import '../helpers/spans.dart';

void main() {
  Future<void> pump(WidgetTester tester, MediaListRow row,
      {ThemeData? theme}) async {
    await tester.pumpWidget(MaterialApp(
        theme: theme ?? darkTheme,
        home: Scaffold(body: SingleChildScrollView(child: row))));
    await tester.pump();
  }

  /// The 4dp bar that peeks above a playlist's thumbnail.
  Finder stackBar() => find.byWidgetPredicate((w) =>
      w is Container &&
      w.constraints?.maxHeight == 4 &&
      w.decoration is BoxDecoration);

  testWidgets('shows the title and its details', (tester) async {
    await pump(
        tester,
        const MediaListRow(
            cover: '',
            title: 'Sabbath Sermons',
            details: '48 videos · Oct 18'));

    expect(find.text('Sabbath Sermons'), findsOneWidget);
    expect(find.text('48 videos · Oct 18'), findsOneWidget);
    expect(stackBar(), findsNothing);
  });

  testWidgets('a video shows its length on the thumbnail', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
        tester,
        const MediaListRow(
            cover: '', title: 'Night 1', details: 'Mar 2', badge: '1:12:40'));

    expect(find.text('1:12:40'), findsOneWidget);
    expect(find.text('Mar 2'), findsOneWidget);
    // It is on the picture, and read out with the title.
    expect(find.bySemanticsLabel('Night 1, 1:12:40, Mar 2'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('no length, no badge', (tester) async {
    await pump(tester,
        const MediaListRow(cover: '', title: 'Night 1', details: 'Mar 2'));
    expect(find.text('1:12:40'), findsNothing);
  });

  testWidgets('a playlist is stacked', (tester) async {
    await pump(
        tester,
        const MediaListRow(
            cover: '', title: 'P', details: '3 videos', stacked: true));
    expect(stackBar(), findsOneWidget);
  });

  testWidgets('marks the searched words in the title', (tester) async {
    await pump(
        tester,
        const MediaListRow(
            cover: '',
            title: 'Dare to Be a Daniel',
            details: '',
            query: 'daniel'));

    final marked = markedWords(tester);
    expect(marked, ['Daniel']);
  });

  testWidgets('live and downloaded badges', (tester) async {
    await pump(
        tester,
        const MediaListRow(
            cover: '',
            title: 'T',
            details: 'Back soon',
            liveNow: true,
            downloaded: true));

    expect(find.text(AppConstants.liveNow), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('tapping it calls back, and it reads as one button',
      (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pump(
        tester,
        MediaListRow(
            cover: '',
            title: 'Night 1',
            details: '1:12:40 · Mar 2',
            onTap: () => taps++));

    await tester.tap(find.text('Night 1'));
    expect(taps, 1);
    expect(find.bySemanticsLabel('Night 1, 1:12:40 · Mar 2'), findsOneWidget);
    handle.dispose();
  });

  test('formats a length and a date', () {
    expect(
        MediaListRow.length(const Duration(hours: 1, minutes: 12, seconds: 40)),
        '1:12:40');
    expect(MediaListRow.length(const Duration(minutes: 4, seconds: 5)), '4:05');
    final now = DateTime(2026, 10, 20);
    expect(MediaListRow.date(DateTime(2026, 3, 2), now: now), 'Mar 2');
    expect(MediaListRow.date(DateTime(2025, 12, 20), now: now), 'Dec 20, 2025');
  });

  group('accessibility', () {
    setUp(mockPluginChannels);

    for (final (name, theme) in [('dark', darkTheme), ('light', lightTheme)]) {
      testWidgets('meets the guidelines ($name)', (tester) async {
        await pump(
            tester,
            MediaListRow(
                cover: '',
                title: 'Dare to Be a Daniel',
                details: '18:40 · Mar 8',
                query: 'daniel',
                onTap: () {}),
            theme: theme);
        await expectAccessible(tester);
      });
    }
  });
}
