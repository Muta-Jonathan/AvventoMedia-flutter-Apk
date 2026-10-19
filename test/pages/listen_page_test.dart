import 'package:avvento_media/apis/mock_presenter_repository.dart';
import 'package:avvento_media/apis/schedule_repository.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/apis/presenter_repository.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/connectivity_controller.dart';
import 'package:avvento_media/controller/download_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/controller/podcast_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/controller/presenters_controller.dart';
import 'package:avvento_media/controller/schedule_controller.dart';
import 'package:avvento_media/models/presenter_model.dart';
import 'package:avvento_media/models/radiomodel/downloaded_episode_model.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:avvento_media/models/radiomodel/radio_station_model.dart';
import 'package:avvento_media/models/schedule_slot.dart';
import 'package:avvento_media/pages/listen_page.dart';
import 'package:avvento_media/routes/routes.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/providers/radio_podcast_provider.dart';
import 'package:avvento_media/widgets/providers/radio_station_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

/// Presenters that never load.
class _FailingPresenters implements PresenterRepository {
  @override
  Future<List<Presenter>> fetchPresenters() async => throw Exception('offline');
  @override
  Future<Presenter> fetchPresenter(String id) async =>
      throw Exception('offline');
}

class _Schedule implements ScheduleRepository {
  @override
  Future<List<ScheduleSlot>> fetchSlots() async => [
        for (final (i, t) in ['Sermons', 'Eriiso', 'Desire of Ages'].indexed)
          ScheduleSlot(
            title: t,
            start: DateTime.utc(2026, 10, 20, 9).add(Duration(hours: i)),
            end: DateTime.utc(2026, 10, 20, 10).add(Duration(hours: i)),
          ),
      ];
}

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
    lastUpdated: DateTime(2026));

void main() {
  late FakeAudioPlayer player;

  /// What the connectivity check reports; change it before tapping Retry.
  var connection = ConnectivityResult.wifi;

  /// A widget test that removes the page and the controllers (the schedule
  /// keeps a timer) before it ends.
  void listenTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox());
        // Closes the controllers (reset alone leaves the schedule's timer).
        Get.deleteAll(force: true);
        Get.reset();
      }
    });
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final station = RadioStation(
    id: 7,
    nowPlayingTitle: 'It Is Well With My Soul',
    artist: 'Heritage Singers',
    imageUrl: '',
    streamUrl: 'https://radio/stream',
    duration: 240,
    elapsed: 10,
    nextProgram: '',
  );

  Future<void> pump(
    WidgetTester tester, {
    RadioStation? live,
    List<RadioPodcast>? shows,
    ThemeData? theme,
    bool continueListening = true,
    double width = 390,
    bool offline = false,
    bool presentersFail = false,
    bool podcastsFail = false,
    bool downloadFirst = false,
  }) async {
    connection = offline ? ConnectivityResult.none : ConnectivityResult.wifi;
    tester.view.physicalSize = Size(width * 3, 1800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    player = FakeAudioPlayer();
    Get.put(AudioPlayerController(player: player, startAudioService: false));
    final queue = Get.put(PodcastEpisodeController());
    Get.put(LibraryController());
    Get.put(DownloadController());
    Get.put(PodcastController());
    Get.put(ConnectivityController(
        changes: const Stream.empty(), check: () async => [connection]));
    Get.put(PresentersController(
        repository:
            presentersFail ? _FailingPresenters() : MockPresenterRepository()));
    Get.put(ScheduleController(
        repository: _Schedule(),
        clock: () => DateTime.utc(2026, 10, 20, 9, 30)));
    final progress = Get.put(EpisodeProgressController());
    await progress.ready;

    if (continueListening) {
      final genesis =
          (await MockPresenterRepository().fetchPresenter('denis-mukaisa'))
              .singles
              .first;
      queue.setQueue([genesis], showTitle: 'Devotions');
      progress.progress[genesis.id] = const EpisodeProgress(
          position: Duration(minutes: 6), duration: Duration(minutes: 20));
      progress.recents.add(RecentEpisode(genesis, 'Devotions'));
      if (downloadFirst) {
        Get.find<DownloadController>().downloads[genesis.id] =
            DownloadedEpisode(
                episode: genesis,
                showTitle: 'Devotions',
                filePath: '/tmp/${genesis.id}.mp3',
                bytes: 1,
                downloadedAt: DateTime(2026));
      }
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<RadioStationProvider>(
            create: (_) => RadioStationProvider.fixed(live ?? station)),
        ChangeNotifierProvider<RadioPodcastProvider>(
            create: (_) => RadioPodcastProvider(
                podcasts: podcastsFail
                    ? const []
                    : shows ??
                        [
                          show('1', 'Old Testament KJV Dramatized', 748),
                          show('2', 'The Desire of Ages (Dramatized)', 87),
                          show('3', 'Wellness Voice', 25),
                        ])),
      ],
      child: GetMaterialApp(
        theme: theme ?? darkTheme,
        home: const ListenPage(),
        getPages: [
          GetPage(
              name: Routes.presenters,
              page: () => const Scaffold(body: Text('presenters page'))),
          GetPage(
              name: Routes.podcastList,
              page: () => const Scaffold(body: Text('podcast list page'))),
          GetPage(
              name: Routes.podcastEpisodeList,
              page: () => const Scaffold(body: Text('episode list page'))),
        ],
      ),
    ));
    await tester.pumpAndSettle();
  }

  listenTest('shows the live card, schedule, presenters and podcasts',
      (tester) async {
    await pump(tester);

    expect(find.text(AppConstants.listenTitle), findsOneWidget);
    expect(find.text(AppConstants.liveBadge), findsOneWidget);
    expect(find.text('It Is Well With My Soul'), findsOneWidget);
    expect(find.text('Heritage Singers'), findsOneWidget);
    expect(find.text(AppConstants.listenLive), findsOneWidget);

    expect(find.text(AppConstants.upNext), findsOneWidget);
    expect(find.textContaining('Your time'), findsOneWidget);
    expect(find.text(AppConstants.onNowLabel), findsOneWidget);
    expect(find.text(AppConstants.upNextLabel), findsOneWidget);
    expect(find.text(AppConstants.laterLabel), findsOneWidget);
    expect(find.text('Eriiso'), findsOneWidget);

    expect(find.text(AppConstants.continueListening), findsOneWidget);
    expect(find.text(AppConstants.minLeft(14)), findsOneWidget);

    expect(find.text(AppConstants.presenters), findsOneWidget);
    expect(find.text('Pr. Okello Samuel'), findsOneWidget);
  });

  listenTest('podcasts split into in-order and newest-first rails',
      (tester) async {
    await pump(tester);
    await tester.scrollUntilVisible(find.text(AppConstants.dailyAndWeekly), 400,
        scrollable: find.byType(Scrollable).first);

    expect(find.text(AppConstants.seeAllCount(3)), findsOneWidget);
    expect(find.text(AppConstants.seriesAndBible), findsOneWidget);
    expect(find.text(AppConstants.playsInOrder), findsOneWidget);
    expect(find.text(AppConstants.newestFirstTag), findsOneWidget);
    expect(find.text('748 episodes'), findsOneWidget);
    expect(find.text('Wellness Voice'), findsOneWidget);
  });

  listenTest('Continue listening is hidden when there is nothing to resume',
      (tester) async {
    await pump(tester, continueListening: false);
    expect(find.text(AppConstants.continueListening), findsNothing);
  });

  listenTest('See all opens the presenters and podcast lists', (tester) async {
    await pump(tester);
    await tester.tap(find.text(AppConstants.seeAll));
    await tester.pumpAndSettle();
    expect(find.text('presenters page'), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text(AppConstants.seeAllCount(3)), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text(AppConstants.seeAllCount(3)));
    await tester.pumpAndSettle();
    expect(find.text('podcast list page'), findsOneWidget);
  });

  listenTest('a podcast opens its episode list', (tester) async {
    await pump(tester);
    await tester.scrollUntilVisible(find.text('Wellness Voice'), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Wellness Voice'));
    await tester.pumpAndSettle();

    expect(find.text('episode list page'), findsOneWidget);
    expect(Get.find<PodcastController>().selectedEpisode.value?.id, '3');
  });

  listenTest('the round button starts the radio and then pauses it',
      (tester) async {
    await pump(tester);
    final audio = Get.find<AudioPlayerController>();

    await tester.tap(find.bySemanticsLabel(AppConstants.playLiveRadio));
    await tester.pump();
    expect(audio.isLive.value, isTrue);
    expect(audio.currentMediaItem?.title, 'It Is Well With My Soul');
    expect(player.calls, containsAllInOrder(['setAudioSource', 'play']));

    player.emitState(true, ProcessingState.ready);
    await tester.pump();
    expect(find.text(AppConstants.playingLive), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(AppConstants.pauseLiveRadio));
    await tester.pump();
    // The radio has no pause: it stops.
    expect(player.calls.last, 'stop');
  });

  listenTest('waits for the station before offering play', (tester) async {
    await pump(tester,
        live: RadioStation(
            id: 0,
            nowPlayingTitle: '',
            artist: '',
            imageUrl: '',
            streamUrl: '',
            duration: 0,
            elapsed: 0,
            nextProgram: ''));
    await tester.tap(find.bySemanticsLabel(AppConstants.playLiveRadio));
    await tester.pump();
    expect(player.calls, isNot(contains('setAudioSource')));
  });

  listenTest('fits a 360dp phone at 130% text in both themes', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pump(tester, width: 360);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    Get.deleteAll(force: true);
    Get.reset();
    await pump(tester, theme: lightTheme, width: 360);
    expect(tester.takeException(), isNull);
  });

  group('offline', () {
    listenTest('shows the pill, the banner and a disabled live card',
        (tester) async {
      await pump(tester, offline: true);

      expect(find.text(AppConstants.offline), findsOneWidget);
      expect(find.text(AppConstants.showingDownloadsOnly), findsOneWidget);
      expect(find.text(AppConstants.noConnection), findsOneWidget);
      expect(find.text(AppConstants.retry), findsOneWidget);
      expect(find.bySemanticsLabel(AppConstants.playLiveRadio), findsNothing);
    });

    listenTest('Continue listening keeps only downloaded episodes',
        (tester) async {
      await pump(tester, offline: true);
      expect(find.text(AppConstants.continueListening), findsNothing);
    });

    listenTest('a downloaded episode can still be resumed offline',
        (tester) async {
      await pump(tester, offline: true, downloadFirst: true);
      expect(find.text(AppConstants.continueListening), findsOneWidget);
    });

    listenTest('Retry brings the page back when the connection returns',
        (tester) async {
      await pump(tester, offline: true);

      connection = ConnectivityResult.wifi;
      await tester.tap(find.text(AppConstants.retry));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.showingDownloadsOnly), findsNothing);
      expect(find.text(AppConstants.noConnection), findsNothing);
      expect(find.text(AppConstants.listenLive), findsOneWidget);
      expect(find.text(AppConstants.continueListening), findsOneWidget);
    });

    listenTest('nothing offline appears while online', (tester) async {
      await pump(tester);
      expect(find.text(AppConstants.offline), findsNothing);
      expect(find.text(AppConstants.showingDownloadsOnly), findsNothing);
    });
  });

  group('rails that could not load', () {
    listenTest('podcasts offer Retry', (tester) async {
      await pump(tester, podcastsFail: true);
      expect(find.text(AppConstants.podcastsLoadFailed), findsOneWidget);
      expect(find.text(AppConstants.retry), findsWidgets);
    });

    listenTest('presenters offer Retry', (tester) async {
      await pump(tester, presentersFail: true);
      expect(find.text(AppConstants.presentersLoadFailed), findsOneWidget);
      expect(find.text(AppConstants.retry), findsWidgets);
    });
  });
}
