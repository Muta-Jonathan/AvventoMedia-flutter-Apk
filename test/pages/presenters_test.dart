import 'dart:io';

import 'package:avvento_media/apis/mock_presenter_repository.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/download_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/controller/presenters_controller.dart';
import 'package:avvento_media/models/presenter_model.dart';
import 'package:avvento_media/pages/presenter_page.dart';
import 'package:avvento_media/pages/presenters_page.dart';
import 'package:avvento_media/pages/series_page.dart';
import 'package:avvento_media/routes/routes.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/podcast/episode/episode_actions_sheet.dart';
import 'package:avvento_media/widgets/presenters/presenters_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

void main() {
  late FakeAudioPlayer player;
  Directory? dir;

  tearDown(() {
    Get.reset();
    if (dir?.existsSync() ?? false) dir!.deleteSync(recursive: true);
    dir = null;
  });

  Future<void> pump(WidgetTester tester, Widget home,
      {ThemeData? theme, List<GetPage>? routes}) async {
    if (tester.view.physicalSize == const Size(2400, 1800)) {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }
    SharedPreferences.setMockInitialValues({});
    final tmp = dir = Directory.systemTemp.createTempSync('presenters_test');
    player = FakeAudioPlayer();
    Get.put(AudioPlayerController(player: player, startAudioService: false));
    Get.put(PodcastEpisodeController());
    Get.put(EpisodeProgressController());
    Get.put(LibraryController());
    Get.put(DownloadController(
      client: () => MockClient(
          (_) async => http.Response.bytes(List.filled(512, 1), 200)),
      directory: () async => tmp,
      notify: (_, {actionLabel, onAction}) {},
    ));
    Get.put(PresentersController(repository: MockPresenterRepository()));
    await tester.pumpWidget(GetMaterialApp(
        theme: theme ?? darkTheme, home: home, getPages: routes));
    await tester.pumpAndSettle();
  }

  group('Presenters list', () {
    testWidgets('lists presenters with sermon counts and genres',
        (tester) async {
      await pump(tester, const PresentersPage());

      expect(find.text(AppConstants.presenters), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('Pr. Okello Samuel'), findsOneWidget);
      expect(find.text('37 sermons · Prophecy'), findsOneWidget);
    });

    testWidgets('genre chips filter the list', (tester) async {
      await pump(tester, const PresentersPage());

      await tester.ensureVisible(find.text('Health'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();
      expect(find.text('Sis. Kisakye Florence'), findsOneWidget);
      expect(find.text('Dr. Kaweesi Tadeo'), findsOneWidget);
      expect(find.text('Pr. Okello Samuel'), findsNothing);
    });

    testWidgets('no results shows one message and Clear search',
        (tester) async {
      await pump(tester, const PresentersPage());

      await tester.enterText(find.byType(TextField), 'Kato');
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.noPresentersFound), findsOneWidget);
      expect(find.text(AppConstants.noResultsFor('Kato')), findsOneWidget);

      await tester.tap(find.text(AppConstants.clearSearch).last);
      await tester.pumpAndSettle();
      expect(find.text('Pr. Okello Samuel'), findsOneWidget);
    });
  });

  group('Presenter page', () {
    testWidgets('Series and Sermons tabs; the tab is kept per presenter',
        (tester) async {
      await pump(tester, const PresenterPage(presenterId: 'denis-mukaisa'));

      expect(find.text('Series  1', findRichText: true), findsOneWidget);
      expect(find.text('Sermons  3', findRichText: true), findsOneWidget);
      expect(find.text('Final Forerunner'), findsOneWidget);
      expect(find.text('3 parts'), findsOneWidget);
      expect(find.text('Standing Firm in the Last Days'), findsNothing);

      await tester.tap(find.text('Sermons  3', findRichText: true));
      await tester.pumpAndSettle();
      expect(find.text('Standing Firm in the Last Days'), findsOneWidget);
      expect(find.text('Final Forerunner'), findsNothing);

      // Reopening the presenter keeps the Sermons tab.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(GetMaterialApp(
          theme: darkTheme,
          home: const PresenterPage(presenterId: 'denis-mukaisa')));
      await tester.pumpAndSettle();
      expect(find.text('Standing Firm in the Last Days'), findsOneWidget);
    });

    testWidgets('series only: a grid, no tabs; a card opens the series',
        (tester) async {
      await pump(tester, const PresenterPage(presenterId: 'kiiza-samuel-akiki'),
          routes: Routes.routes);

      expect(find.text('Series  1', findRichText: true), findsNothing);
      expect(find.text('6 parts'), findsOneWidget);

      await tester.tap(find.text('Victory Amidst Troubles'));
      await tester.pumpAndSettle();
      expect(find.byType(SeriesPage), findsOneWidget);
      expect(find.text(AppConstants.seriesLabel), findsOneWidget);
      expect(find.text('Victory Amidst Troubles Pt. 1'), findsOneWidget);
    });

    testWidgets('a started series shows its progress', (tester) async {
      await pump(tester, const PresenterPage(presenterId: 'denis-mukaisa'));
      await tester.tap(find.text('Series  1', findRichText: true));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.partsOf(1, 3)), findsNothing);

      Get.find<EpisodeProgressController>().progress['mock-ff1'] =
          const EpisodeProgress(played: true);
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.partsOf(1, 3)), findsOneWidget);
    });

    testWidgets('Download all on the series page queues every part',
        (tester) async {
      final kiiza =
          await MockPresenterRepository().fetchPresenter('kiiza-samuel-akiki');
      await pump(
          tester, SeriesPage(presenter: kiiza, series: kiiza.series.single));
      final downloads = Get.find<DownloadController>();

      await tester.tap(find.bySemanticsLabel(AppConstants.downloadAll(6)));
      await tester.pump();
      expect(downloads.tasks.length + downloads.downloads.length, 6);
    });

    testWidgets('Play latest plays the newest sermon', (tester) async {
      await pump(tester, const PresenterPage(presenterId: 'denis-mukaisa'));

      await tester.tap(find.text(AppConstants.playLatest));
      await tester.pumpAndSettle();
      expect(Get.find<AudioPlayerController>().currentMediaItem?.title,
          'Standing Firm in the Last Days');
    });

    testWidgets('fits a 360dp phone at 130% text in both themes',
        (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 740 * 3);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pump(tester, const PresenterPage(presenterId: 'denis-mukaisa'));
      expect(tester.takeException(), isNull);
      Get.reset();
      await pump(tester, const PresentersPage(), theme: lightTheme);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('rail shows presenters and opens a presenter', (tester) async {
    await pump(tester, const Scaffold(body: PresentersRail()));

    expect(find.text('Pr. Okello Samuel'), findsOneWidget);
    expect(find.text('37 sermons'), findsOneWidget);
    expect(
        find.bySemanticsLabel('Pr. Okello Samuel, 37 sermons'), findsOneWidget);
  });

  testWidgets('episode ⋯ offers Go to presenter when the artist matches',
      (tester) async {
    await pump(tester, const Scaffold(body: SizedBox()));
    final denis =
        await MockPresenterRepository().fetchPresenter('denis-mukaisa');
    final context = tester.element(find.byType(SizedBox));

    EpisodeActionsSheet.show(context, denis.singles.first,
        showTitle: 'Devotions');
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.goToPresenter), findsOneWidget);
  });

  group('New-sermon ring', () {
    const day = 86400;
    final now = DateTime(2026, 10, 19);
    final nowSecs = now.millisecondsSinceEpoch ~/ 1000;
    Presenter presenter(int latestAt) => Presenter(
        id: 'p',
        name: 'Pr. P',
        image: '',
        genre: '',
        sermonCount: 1,
        seriesCount: 0,
        latestAt: latestAt);

    test('shows for 14 days until the presenter is opened', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = PresentersController(
          repository: MockPresenterRepository(), clock: () => now);
      final fresh = presenter(nowSecs - 3 * day);

      expect(controller.hasNew(fresh), isTrue);
      expect(controller.hasNew(presenter(nowSecs - 15 * day)), isFalse);
      expect(controller.hasNew(presenter(0)), isFalse);

      await controller.markSeen(fresh);
      expect(controller.hasNew(fresh), isFalse);
      // Something newer brings it back.
      expect(controller.hasNew(presenter(nowSecs - day)), isTrue);
    });

    test('seen presenters are remembered', () async {
      SharedPreferences.setMockInitialValues({});
      final fresh = presenter(nowSecs - day);
      await PresentersController(
          repository: MockPresenterRepository(),
          clock: () => now).markSeen(fresh);

      final next = PresentersController(
          repository: MockPresenterRepository(), clock: () => now);
      next.onInit();
      await Future<void>.delayed(Duration.zero);
      expect(next.hasNew(fresh), isFalse);
    });
  });
}
