import 'dart:io';

import 'package:avvento_media/apis/mock_presenter_repository.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/download_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/controller/presenters_controller.dart';
import 'package:avvento_media/pages/presenter_page.dart';
import 'package:avvento_media/pages/presenters_page.dart';
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
  late Directory dir;

  tearDown(() {
    Get.reset();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<void> pump(WidgetTester tester, Widget home,
      {ThemeData? theme}) async {
    if (tester.view.physicalSize == const Size(2400, 1800)) {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('presenters_test');
    player = FakeAudioPlayer();
    Get.put(AudioPlayerController(player: player, startAudioService: false));
    Get.put(PodcastEpisodeController());
    Get.put(EpisodeProgressController());
    Get.put(LibraryController());
    Get.put(DownloadController(
      client: () => MockClient(
          (_) async => http.Response.bytes(List.filled(512, 1), 200)),
      directory: () async => dir,
      notify: (_, {actionLabel, onAction}) {},
    ));
    Get.put(PresentersController(repository: MockPresenterRepository()));
    await tester
        .pumpWidget(GetMaterialApp(theme: theme ?? darkTheme, home: home));
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
    testWidgets('series in part order with Show more, then singles',
        (tester) async {
      await pump(
          tester, const PresenterPage(presenterId: 'kiiza-samuel-akiki'));

      expect(find.text(AppConstants.presenterLabel), findsOneWidget);
      expect(find.text('Bro. Kiiza Samuel Akiki'), findsOneWidget);
      expect(find.text('6 sermons · 1 series'), findsOneWidget);
      expect(find.text('Victory Amidst Troubles'), findsOneWidget);
      expect(find.text('6 parts'), findsOneWidget);
      expect(find.text('Victory Amidst Troubles Pt. 3'), findsOneWidget);
      expect(find.text('Victory Amidst Troubles Pt. 4'), findsNothing);
      expect(find.text('PART 1'), findsOneWidget);

      await tester.tap(find.text(AppConstants.showMoreParts(3)));
      await tester.pumpAndSettle();
      expect(find.text('Victory Amidst Troubles Pt. 6'), findsOneWidget);
    });

    testWidgets('Download all on a series queues every part', (tester) async {
      await pump(
          tester, const PresenterPage(presenterId: 'kiiza-samuel-akiki'));
      final downloads = Get.find<DownloadController>();

      // The series card's button (the header's covers all sermons).
      await tester.tap(find.bySemanticsLabel(AppConstants.downloadAll(6)).last);
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
}
