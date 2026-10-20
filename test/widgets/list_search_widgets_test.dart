import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/search_index_controller.dart';
import 'package:avvento_media/search/search_models.dart';
import 'package:avvento_media/search/search_source.dart';
import 'package:avvento_media/themes/avvento_colors.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/common/media_list_row.dart';
import 'package:avvento_media/widgets/search/list_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/a11y.dart';
import '../helpers/spans.dart';

class _Video {
  const _Video(this.title, this.daysAgo, this.minutes);
  final String title;
  final int daysAgo;
  final int minutes;
}

final now = DateTime(2026, 10, 20);

const videos = [
  _Video('Night 1 · Daniel 2: The Dream of Kingdoms', 30, 72),
  _Video('Night 2 · The Little Horn of Daniel 7', 29, 58),
  _Video('Night 3 · The 2300 Days', 28, 65),
  _Video('Night 4 · Daniel 9 and the Messiah', 27, 62),
  _Video('Night 5 · The Mark of the Beast', 26, 68),
  _Video('Questions on Daniel and Revelation', 25, 42),
  _Video('Night 6 · The Seal of God', 24, 55),
  _Video('Youth Hour · Dare to Be a Daniel', 22, 19),
  _Video('Daniel’s Prayer', 20, 7),
  _Video('Praise and Worship Night', 10, 90),
  _Video('Night 7 · Babylon Is Fallen', 8, 63),
  _Video('Night 8 · The Millennium', 5, 59),
];

class _Page extends StatelessWidget {
  const _Page({required this.items});
  final List<_Video> items;

  @override
  Widget build(BuildContext context) => ListSearchScope(
        builder: (context, search) => Scaffold(
          body: CustomScrollView(
            controller: search.scroll,
            slivers: [
              if (search.controller.searching)
                ...listSearchTop(context, search,
                    hint: AppConstants.searchThisPlaylist,
                    unit: 'videos',
                    showLength: true)
              else ...[
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Theme.of(context).avvento.bg,
                  title: Text('Prophecy Seminar',
                      style: TextStyle(color: Theme.of(context).avvento.text)),
                  actions: [ListSearchButton(search: search)],
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: 300, child: Text('HEADER'))),
              ],
              ListSearchList<_Video>(
                items: items,
                search: search,
                titleOf: (v) => v.title,
                dateOf: (v) => now.subtract(Duration(days: v.daysAgo)),
                durationOf: (v) => Duration(minutes: v.minutes),
                itemBuilder: (context, v, query) => MediaListRow(
                  cover: '',
                  title: v.title,
                  details: MediaListRow.length(Duration(minutes: v.minutes)),
                  query: query,
                ),
              ),
            ],
          ),
        ),
      );
}

void main() {
  Future<void> pump(WidgetTester tester,
      {List<_Video> items = videos,
      ThemeData? theme,
      double width = 600}) async {
    // Wider than a phone: the test font is far wider than a real one.
    tester.view.physicalSize = Size(width * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    Get.put(SearchIndexController(source: _Empty()));
    await tester.pumpWidget(
        GetMaterialApp(theme: theme ?? darkTheme, home: _Page(items: items)));
    await tester.pump();
    await tester.pump(); // The list reports its size after the first frame.
  }

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    Get.deleteAll(force: true);
    Get.reset();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byTooltip(AppConstants.search));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
  }

  double top(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  testWidgets('a short list has no search', (tester) async {
    await pump(tester, items: videos.take(8).toList());
    expect(find.byTooltip(AppConstants.search), findsNothing);
    await leave(tester);
  });

  testWidgets('a longer list does, and opening swaps the header for the field',
      (tester) async {
    await pump(tester);
    expect(find.text('HEADER'), findsOneWidget);
    await open(tester);

    expect(find.text('HEADER'), findsNothing);
    expect(find.text('Prophecy Seminar'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('12 videos'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('the count and both chips fit the row, none cut off',
      (tester) async {
    // The count and the chips used to share the row half and half, which cut
    // the Sort chip in two. 480 wide fits them in the (wide) test font.
    await pump(tester, width: 480);
    await open(tester);

    final count = tester.getRect(find.text('12 videos'));
    final sort = tester.getRect(find.text('Relevance'));
    final length = tester.getRect(find.text(AppConstants.length));
    expect(count.left, greaterThanOrEqualTo(20));
    expect(sort.left, greaterThan(count.right));
    expect(length.left, greaterThan(sort.right));
    expect(length.right, lessThanOrEqualTo(480 - 20));
    await leave(tester);
  });

  testWidgets('typing narrows the list, counts it and marks the words',
      (tester) async {
    await pump(tester);
    await open(tester);
    await type(tester, 'daniel');

    expect(find.text('6 of 12'), findsOneWidget);
    expect(find.text('Praise and Worship Night'), findsNothing);
    expect(markedWords(tester), isNotEmpty);
    // Best match first.
    expect(top(tester, 'Daniel’s Prayer'),
        lessThan(top(tester, 'Night 1 · Daniel 2: The Dream of Kingdoms')));
    await leave(tester);
  });

  testWidgets('Sort changes the order', (tester) async {
    await pump(tester);
    await open(tester);
    await type(tester, 'daniel');

    await tester.tap(find.text(ListSortLabels.relevance));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ListSortLabels.oldest));
    await tester.pumpAndSettle();

    expect(find.text(ListSortLabels.oldest), findsOneWidget);
    expect(top(tester, 'Night 1 · Daniel 2: The Dream of Kingdoms'),
        lessThan(top(tester, 'Daniel’s Prayer')));
    await leave(tester);
  });

  testWidgets('Length narrows it, shows its value and clears', (tester) async {
    await pump(tester);
    await open(tester);

    await tester.tap(find.text(AppConstants.length));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Over 60 min'));
    await tester.pumpAndSettle();
    expect(find.text('Over 60 min'), findsOneWidget);
    expect(find.text('6 of 12'), findsOneWidget);
    expect(find.text('Daniel’s Prayer'), findsNothing);

    await tester
        .tap(find.bySemanticsLabel(AppConstants.removeFilter('Over 60 min')));
    await tester.pumpAndSettle();
    expect(find.text('12 videos'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('no match says so and offers a way out', (tester) async {
    await pump(tester);
    await open(tester);
    await type(tester, 'kato');

    expect(find.text(AppConstants.nothingHere('kato')), findsOneWidget);
    expect(find.text('0 of 12'), findsOneWidget);

    await tester.tap(find.text(AppConstants.clearSearchButton));
    await tester.pumpAndSettle();
    expect(find.text('12 videos'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('"Search all of Avvento" hands the query to Search',
      (tester) async {
    await pump(tester);
    await open(tester);
    await type(tester, 'kato');

    await tester.tap(find.text(AppConstants.searchAllOfAvvento));
    await tester.pump();
    expect(Get.find<SearchIndexController>().pendingQuery.value, 'kato');
    await leave(tester);
  });

  testWidgets('Cancel brings the header back where you were', (tester) async {
    await pump(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
    await tester.pumpAndSettle();
    final before = tester
        .getTopLeft(find.text('Night 1 · Daniel 2: The Dream of Kingdoms'))
        .dy;

    await open(tester);
    await type(tester, 'daniel');
    await tester.tap(find.text(AppConstants.cancel));
    await tester.pumpAndSettle();

    expect(find.text('HEADER'), findsOneWidget);
    expect(find.text('12 videos'), findsNothing);
    expect(
        tester
            .getTopLeft(find.text('Night 1 · Daniel 2: The Dream of Kingdoms'))
            .dy,
        closeTo(before, 1));
    await leave(tester);
  });

  group('accessibility', () {
    setUp(mockPluginChannels);

    for (final (name, theme) in [('dark', darkTheme), ('light', lightTheme)]) {
      testWidgets('closed and open meet the guidelines ($name)',
          (tester) async {
        await pump(tester, theme: theme);
        await expectAccessible(tester);

        await open(tester);
        await type(tester, 'daniel');
        await expectAccessible(tester);
        await leave(tester);
      });
    }
  });
}

/// The sort menu's labels.
abstract class ListSortLabels {
  static const relevance = 'Relevance';
  static const oldest = 'Oldest';
}

class _Empty implements SearchSource {
  @override
  Stream<List<SearchEntry>> load() async* {}
}
