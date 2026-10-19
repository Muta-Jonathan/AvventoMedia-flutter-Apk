import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/search/group_search.dart';
import 'package:avvento_media/search/search_models.dart';
import 'package:avvento_media/themes/avvento_colors.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/search/group_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/a11y.dart';

SearchEntry entryOf(String title) => SearchEntry(
    kind: SearchKind.video, id: title, title: title, payload: title);

const titles = [
  'Sabbath School Lesson 1',
  'Praise and Worship Night',
  'Daniel and Revelation Seminar',
  'Dare to Be a Daniel',
  'Lions Den Story',
];

void main() {
  group('GroupSearch.filter', () {
    test('an empty query keeps everything in order', () {
      expect(GroupSearch.filter(titles, '', entryOf), titles);
      expect(GroupSearch.filter(titles, '   ', entryOf), titles);
    });

    test('keeps only matches, best first', () {
      expect(GroupSearch.filter(titles, 'daniel', entryOf),
          ['Daniel and Revelation Seminar', 'Dare to Be a Daniel']);
    });

    test('ties keep the page order', () {
      expect(GroupSearch.filter(['b one', 'a one', 'c one'], 'one', entryOf),
          ['b one', 'a one', 'c one']);
    });

    test('nothing matching gives nothing', () {
      expect(GroupSearch.filter(titles, 'zzzz', entryOf), isEmpty);
    });
  });

  group('the field and the list', () {
    late ValueNotifier<String> query;

    int rows() =>
        titles.where((t) => find.text(t).evaluate().isNotEmpty).length;

    Widget app(ThemeData theme) {
      query = ValueNotifier('');
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: GroupSearchField(
                    query: query, hint: 'Search this playlist')),
            GroupSearchList<String>(
              items: titles,
              query: query,
              entryOf: entryOf,
              builder: (context, shown) => SliverList.builder(
                itemCount: shown.length,
                itemBuilder: (context, i) => SizedBox(
                  height: 56,
                  child: Text(shown[i],
                      style: TextStyle(color: Theme.of(context).avvento.text)),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    testWidgets('typing narrows the list after a short pause', (tester) async {
      await tester.pumpWidget(app(darkTheme));
      expect(rows(), 5);

      await tester.enterText(find.byType(TextField), 'daniel');
      // Not yet: the list waits for the typing to pause.
      expect(rows(), 5);
      await tester.pump(const Duration(milliseconds: 200));
      expect(rows(), 2);
      expect(find.text('Dare to Be a Daniel'), findsOneWidget);
      expect(find.text('Lions Den Story'), findsNothing);
    });

    testWidgets('clearing brings everything back', (tester) async {
      await tester.pumpWidget(app(darkTheme));
      await tester.enterText(find.byType(TextField), 'daniel');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.bySemanticsLabel(AppConstants.clearSearch));
      await tester.pump();
      expect(rows(), 5);
      expect(query.value, '');
    });

    testWidgets('Cancel clears and closes the keyboard', (tester) async {
      await tester.pumpWidget(app(darkTheme));
      await tester.enterText(find.byType(TextField), 'lions');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text(AppConstants.cancel));
      await tester.pump();
      expect(rows(), 5);
      expect(find.text(AppConstants.cancel), findsNothing);
    });

    testWidgets('no match says so, in this list', (tester) async {
      await tester.pumpWidget(app(darkTheme));
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump(const Duration(milliseconds: 200));

      expect(rows(), 0);
      expect(find.text(AppConstants.nothingHere('zzzz')), findsOneWidget);
    });

    testWidgets('a list with nothing in it is left to the page',
        (tester) async {
      final empty = ValueNotifier('x');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomScrollView(slivers: [
            GroupSearchList<String>(
              items: const [],
              query: empty,
              entryOf: entryOf,
              builder: (context, shown) =>
                  const SliverToBoxAdapter(child: Text('page decides')),
            ),
          ]),
        ),
      ));
      expect(find.text('page decides'), findsOneWidget);
    });

    group('accessibility', () {
      setUp(mockPluginChannels);

      for (final (name, theme) in [
        ('dark', darkTheme),
        ('light', lightTheme)
      ]) {
        testWidgets('meets the guidelines ($name)', (tester) async {
          await tester.pumpWidget(app(theme));
          await tester.enterText(find.byType(TextField), 'daniel');
          await tester.pump(const Duration(milliseconds: 200));
          await expectAccessible(tester);
        });
      }
    });
  });
}
