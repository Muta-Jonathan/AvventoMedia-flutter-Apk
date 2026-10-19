import 'dart:io';

import 'package:avvento_media/apis/mock_presenter_repository.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/connectivity_controller.dart';
import 'package:avvento_media/controller/download_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/controller/podcast_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/controller/search_index_controller.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:avvento_media/pages/search_page.dart';
import 'package:avvento_media/routes/routes.dart';
import 'package:avvento_media/search/search_models.dart';
import 'package:avvento_media/search/search_source.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/a11y.dart';
import '../helpers/fake_audio_player.dart';

/// Hands the index a fixed list, with no covers so nothing is fetched.
class _Source implements SearchSource {
  _Source(this.entries);
  final List<SearchEntry> entries;

  @override
  Stream<List<SearchEntry>> load() async* {
    yield entries;
  }
}

SearchEntry blank(SearchEntry e) => SearchEntry(
      kind: e.kind,
      id: e.id,
      title: e.title,
      subtitle: e.subtitle,
      presenter: e.presenter,
      source: e.source,
      publishedAt: e.publishedAt,
      duration: e.duration,
      keywords: e.keywords,
      count: e.count,
      payload: e.payload,
    );

RadioPodcast show(String id, String title, int episodes) => RadioPodcast(
    id: id,
    title: title,
    description: '',
    author: '',
    email: '',
    art: '',
    isPublished: true,
    episodes: episodes,
    categories: const [],
    episodesLink: '',
    lastUpdated: DateTime.now());

Future<List<SearchEntry>> entries() async {
  final repo = MockPresenterRepository();
  final out = <SearchEntry>[];
  for (final id in ['denis-mukaisa', 'kiiza-samuel-akiki']) {
    out.addAll(SearchEntries.fromPresenter(await repo.fetchPresenter(id)));
  }
  out.addAll([
    SearchEntries.fromPodcast(show('ot', 'Old Testament KJV Dramatized', 748)),
    SearchEntries.fromPodcast(show('wv', 'Wellness Voice', 25)),
    SearchEntry(
        kind: SearchKind.video,
        id: 'v1',
        title: 'Final Hour Seminar',
        subtitle: SearchSources.main,
        source: SearchSources.main,
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        duration: const Duration(minutes: 72),
        payload: 'video'),
    SearchEntry(
        kind: SearchKind.live,
        id: 'radio',
        title: 'AvventoRadio',
        subtitle: AppConstants.liveRadio,
        source: SearchSources.radio,
        payload: 'live'),
  ]);
  return [for (final e in out) blank(e)];
}

void main() {
  late FakeAudioPlayer player;
  late Directory dir;

  Future<void> pump(
    WidgetTester tester, {
    ThemeData? theme,
    Map<String, Object> prefs = const {},
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width * 3, 1500 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(prefs);
    dir = Directory.systemTemp.createTempSync('search_test');
    player = FakeAudioPlayer();
    Get.put(AudioPlayerController(player: player, startAudioService: false));
    Get.put(PodcastEpisodeController());
    Get.put(EpisodeProgressController());
    Get.put(LibraryController());
    Get.put(PodcastController());
    Get.put(DownloadController(
      directory: () async => dir,
      notify: (_, {actionLabel, onAction}) {},
    ));
    Get.put(ConnectivityController(
        changes: const Stream.empty(), check: () async => []));
    Get.put(SearchIndexController(source: _Source(await entries())));

    await tester.pumpWidget(GetMaterialApp(
      theme: theme ?? darkTheme,
      home: const SearchPage(),
      getPages: [
        GetPage(
            name: Routes.presenter,
            page: () => const Scaffold(body: Text('presenter page'))),
        GetPage(
            name: Routes.podcastEpisodeList,
            page: () => const Scaffold(body: Text('episodes page'))),
      ],
    ));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    // Suggestions follow after a short pause.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester, String text) async {
    await type(tester, text);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    Get.deleteAll(force: true);
    Get.reset();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }

  /// The tabs scroll sideways; bring one into view, then tap it.
  Future<void> tapTab(WidgetTester tester, String semanticsLabel) async {
    final tab = find.bySemanticsLabel(semanticsLabel);
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  Finder tabLabel(String label) =>
      find.bySemanticsLabel(RegExp('^$label(,|\$)'));

  testWidgets('the start shows Recent and Browse', (tester) async {
    await pump(tester, prefs: {
      'search_history': ['Desire of Ages', 'Psalms 23']
    });

    expect(find.text(AppConstants.searchTitle), findsOneWidget);
    expect(find.text(AppConstants.searchHint), findsOneWidget);
    expect(find.text(AppConstants.recent), findsOneWidget);
    expect(find.text('Desire of Ages'), findsOneWidget);
    expect(find.text(AppConstants.browse), findsOneWidget);
    expect(find.text('Presenters'), findsOneWidget);
    expect(find.text(AppConstants.bible), findsOneWidget);
    await leave(tester);
  });

  testWidgets('typing shows suggestions: the query first, then matches',
      (tester) async {
    await pump(tester);
    await type(tester, 'fin');

    expect(find.text(AppConstants.searchTitle), findsNothing);
    expect(find.textContaining('Final Forerunner', findRichText: true),
        findsWidgets);
    expect(find.text('Series · Ev. Denis Mukaisa'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('one letter shows no suggestions', (tester) async {
    await pump(tester);
    await type(tester, 'f');
    expect(find.text('Series · Ev. Denis Mukaisa'), findsNothing);
    expect(find.text(AppConstants.browse), findsOneWidget);
    await leave(tester);
  });

  testWidgets('submitting shows results with tabs, counts and a top result',
      (tester) async {
    await pump(tester);
    await submit(tester, 'final');

    expect(find.text(AppConstants.topResult), findsOneWidget);
    expect(find.text(AppConstants.seriesLabel), findsOneWidget);
    expect(find.text('Final Forerunner'), findsWidgets);
    expect(tabLabel('Sermons'), findsOneWidget);
    expect(tabLabel('Videos, 1'), findsOneWidget);
    expect(find.text('Final Forerunner Pt. 1'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('a tab narrows the results and See all opens it', (tester) async {
    await pump(tester);
    await submit(tester, 'final');

    await tapTab(tester, 'Videos, 1');
    expect(find.text('Final Hour Seminar'), findsOneWidget);
    expect(find.text(AppConstants.topResult), findsNothing);
    expect(find.text('Final Forerunner Pt. 1'), findsNothing);
    await leave(tester);
  });

  testWidgets('submitting saves to Recent, which can be removed and cleared',
      (tester) async {
    await pump(tester);
    await submit(tester, 'final');
    final index = Get.find<SearchIndexController>();
    expect(index.recent.first, 'final');

    await tester.tap(find.bySemanticsLabel(AppConstants.clearSearch));
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.recent), findsOneWidget);
    expect(find.text('final'), findsOneWidget); // In Recent now.

    await tester
        .tap(find.bySemanticsLabel('${AppConstants.removeRecent}: final'));
    await tester.pumpAndSettle();
    expect(index.recent, isEmpty);
    await leave(tester);
  });

  testWidgets('a Browse tile lists everything of that type', (tester) async {
    await pump(tester);
    await tester.tap(find.bySemanticsLabel('Presenters'));
    await tester.pumpAndSettle();

    expect(find.text('Ev. Denis Mukaisa'), findsOneWidget);
    expect(find.text('Bro. Kiiza Samuel Akiki'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('a presenter opens from the results', (tester) async {
    await pump(tester);
    await tester.tap(find.bySemanticsLabel('Presenters'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ev. Denis Mukaisa'));
    await tester.pumpAndSettle();
    expect(find.text('presenter page'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('no matches: a message, and no Clear filters without filters',
      (tester) async {
    await pump(tester);
    await submit(tester, 'zzzz');

    expect(find.text(AppConstants.noResultsTitle), findsOneWidget);
    expect(find.text(AppConstants.noMatchFor('zzzz')), findsOneWidget);
    expect(find.text(AppConstants.clearFilters), findsNothing);
    await leave(tester);
  });

  group('filters', () {
    testWidgets('the sheet filters, shows chips and counts', (tester) async {
      await pump(tester);
      await submit(tester, 'final');

      await tester.tap(find.bySemanticsLabel(AppConstants.filtersCount(0)));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.filters), findsOneWidget);
      expect(find.text(AppConstants.downloadedOnly), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Past week'));
      await tester.pumpAndSettle();
      // Only the video is that recent.
      expect(find.text(AppConstants.showResults(1)), findsOneWidget);

      await tester.tap(find.text(AppConstants.showResults(1)));
      await tester.pumpAndSettle();
      expect(
          find.bySemanticsLabel(AppConstants.filtersCount(1)), findsOneWidget);
      expect(find.bySemanticsLabel(AppConstants.removeFilter('Past week')),
          findsOneWidget);
      await leave(tester);
    });

    testWidgets('no results with filters offers Clear filters', (tester) async {
      await pump(tester);
      await submit(tester, 'forerunner');
      await tester.tap(find.bySemanticsLabel(AppConstants.filtersCount(0)));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Past week'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppConstants.showResults(0)));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.noResultsTitle), findsOneWidget);
      expect(find.text(AppConstants.nothingFor('forerunner')), findsOneWidget);

      await tester.tap(find.text(AppConstants.clearFilters));
      await tester.pumpAndSettle();
      expect(find.text('Final Forerunner'), findsWidgets);
      await leave(tester);
    });

    testWidgets('removing a chip removes the filter', (tester) async {
      await pump(tester);
      await submit(tester, 'final');
      await tester.tap(find.bySemanticsLabel(AppConstants.filtersCount(0)));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Past week'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppConstants.showResults(1)));
      await tester.pumpAndSettle();

      await tester
          .tap(find.bySemanticsLabel(AppConstants.removeFilter('Past week')));
      await tester.pumpAndSettle();
      expect(
          find.bySemanticsLabel(AppConstants.filtersCount(0)), findsOneWidget);
      await leave(tester);
    });

    testWidgets('Presenters has no filters', (tester) async {
      await pump(tester);
      await tester.tap(find.bySemanticsLabel('Presenters'));
      await tester.pumpAndSettle();

      // Tapping it does nothing: there is nothing to filter.
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.filters), findsNothing);
      await leave(tester);
    });
  });

  group('accessibility', () {
    setUp(mockPluginChannels);

    for (final (name, theme) in [('dark', darkTheme), ('light', lightTheme)]) {
      testWidgets('start, suggestions and results meet the guidelines ($name)',
          (tester) async {
        await pump(tester, theme: theme, width: 360, prefs: {
          'search_history': ['Desire of Ages']
        });
        await expectAccessible(tester);

        await type(tester, 'fin');
        await expectAccessible(tester);

        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        await leave(tester);
      });
    }
  });
}
