import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/connectivity_controller.dart';
import 'package:avvento_media/controller/download_controller.dart';
import 'package:avvento_media/controller/episode_progress_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/controller/podcast_controller.dart';
import 'package:avvento_media/controller/podcast_episode_controller.dart';
import 'package:avvento_media/models/radiomodel/podcast_episode_model.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:avvento_media/pages/downloads_page.dart';
import 'package:avvento_media/pages/podcast_episode_list_page.dart';
import 'package:avvento_media/themes/avvento_colors.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/podcast/episode/episode_feed_tile.dart';
import 'package:avvento_media/models/saved_item_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

final _now = DateTime.now();

PodcastEpisode episode(String id,
        {int daysAgo = 0, String? title, int? season, int? number}) =>
    PodcastEpisode(
      id: id,
      title: title ?? 'Episode $id',
      description: 'About episode $id',
      playlistMediaArtist: 'AvventoRadio',
      playlistMediaAlbum: '',
      publishedAt:
          _now.subtract(Duration(days: daysAgo)).millisecondsSinceEpoch ~/ 1000,
      downloadLink: 'https://example.org/$id.mp3',
      publicLink: '',
      isPublished: true,
      art: '',
      media: '',
      seasonNumber: season,
      episodeNumber: number,
    );

RadioPodcast podcastNamed(String title, int episodes) => RadioPodcast(
      id: title,
      title: title,
      description: '',
      author: 'Avvento Radio',
      email: '',
      art: '',
      isPublished: true,
      episodes: episodes,
      categories: const [],
      episodesLink: 'https://example.org/$title',
      lastUpdated: DateTime(2026),
    );

/// Genesis 1–[genesis] and Exodus 1–[exodus], newest first like the API.
List<PodcastEpisode> bibleEpisodes({int genesis = 3, int exodus = 2}) => [
      for (var c = exodus; c >= 1; c--)
        episode('x$c', title: 'Exodus $c', season: 2, number: c),
      for (var c = genesis; c >= 1; c--)
        episode('g$c', title: 'Genesis $c', season: 1, number: c),
    ];

final show = RadioPodcast(
  id: 'show',
  title: 'Sabbath Messages',
  description: 'Weekly sermons.',
  author: 'AvventoRadio',
  email: '',
  art: '',
  isPublished: true,
  episodes: 2,
  categories: const [],
  episodesLink: 'https://example.org/episodes',
  lastUpdated: DateTime(2026),
);

void main() {
  late FakeAudioPlayer player;
  late Directory dir;

  tearDown(() {
    Get.reset();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  // Controllers are created inside each test body (fake-async zone).
  Future<void> pump(WidgetTester tester, Widget home,
      {ThemeData? theme, bool offline = false, RadioPodcast? podcast}) async {
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('feed_test');
    player = FakeAudioPlayer();
    Get.put(AudioPlayerController(player: player, startAudioService: false));
    Get.put(PodcastEpisodeController());
    Get.put(EpisodeProgressController());
    Get.put(DownloadController(
      client: () => MockClient(
          (_) async => http.Response.bytes(List.filled(2048, 1), 200)),
      directory: () async => dir,
      notify: (_, {actionLabel, onAction}) {},
      storage: () async => const StorageInfo(free: 100 << 30, total: 400 << 30),
    ));
    Get.put(LibraryController());
    Get.put(ConnectivityController(
      changes: const Stream.empty(),
      check: () async =>
          [offline ? ConnectivityResult.none : ConnectivityResult.wifi],
    ));
    Get.put(PodcastController()).setSelectedEpisode(podcast ?? show);
    await tester
        .pumpWidget(GetMaterialApp(theme: theme ?? darkTheme, home: home));
    await tester.pumpAndSettle();
  }

  Widget page({bool fail = false}) => PodcastEpisodeListPage(
        fetchEpisodes: (_) async {
          if (fail) throw Exception('offline');
          return [episode('1', daysAgo: 1), episode('2', daysAgo: 30)];
        },
      );

  testWidgets('header and editorial feed', (tester) async {
    await pump(tester, page());

    expect(find.text('Sabbath Messages'), findsOneWidget);
    expect(find.text(AppConstants.playAll), findsOneWidget);
    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('About episode 1'), findsOneWidget);
    // Only the recent episode is NEW.
    expect(find.textContaining(AppConstants.newLabel), findsOneWidget);
  });

  testWidgets('shows default to newest; Oldest flips the list', (tester) async {
    await pump(tester, page());
    double y(String title) => tester.getTopLeft(find.text(title)).dy;

    expect(y('Episode 1'), lessThan(y('Episode 2')));
    await tester.tap(find.text(AppConstants.newestFirst));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppConstants.oldestFirst));
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.oldestFirst), findsOneWidget);
    expect(y('Episode 2'), lessThan(y('Episode 1')));
  });

  testWidgets('series play in order and resume where you left off',
      (tester) async {
    // Tall enough to build every row.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // API order is newest first; parts were published out of order.
    await pump(
        tester,
        PodcastEpisodeListPage(
          fetchEpisodes: (_) async => [
            episode('b', daysAgo: 0, title: 'Faith Pt. 2'),
            episode('c', daysAgo: 5, title: 'Faith Pt. 3'),
            episode('a', daysAgo: 10, title: 'Faith Pt. 1'),
          ],
        ));
    double y(String title) => tester.getTopLeft(find.text(title)).dy;

    expect(y('Faith Pt. 1'), lessThan(y('Faith Pt. 2')));
    expect(y('Faith Pt. 2'), lessThan(y('Faith Pt. 3')));
    expect(find.text('PART 1'), findsOneWidget);
    expect(find.text(AppConstants.playAll), findsOneWidget);

    Get.find<EpisodeProgressController>().setPlayed('a', true);
    await tester.pumpAndSettle();
    // "Resume" with the episode underneath.
    expect(find.text(AppConstants.resume), findsOneWidget);
    expect(find.text('Faith Pt. 2'), findsNWidgets(2));

    await tester.tap(find.text(AppConstants.resume));
    await tester.pumpAndSettle();
    expect(Get.find<AudioPlayerController>().currentMediaItem?.id, 'b');
    // The queue follows the list as shown.
    final queue = Get.find<AudioPlayerController>().playlist!.children;
    expect(queue.map((s) => ((s as IndexedAudioSource).tag as MediaItem).id),
        ['a', 'b', 'c']);
  });

  testWidgets('Download all saves every episode; Remove deletes them',
      (tester) async {
    await pump(tester, page());
    final downloads = Get.find<DownloadController>();

    await tester.tap(find.bySemanticsLabel(AppConstants.downloadAll(2)));
    // File I/O needs real async.
    for (var i = 0; i < 100 && downloads.downloads.length < 2; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.downloadedLabel), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel(AppConstants.downloadedLabel));
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.removeDownloadsQuestion(2)), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, AppConstants.remove));
    for (var i = 0; i < 100 && downloads.downloads.isNotEmpty; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(downloads.downloads, isEmpty);
    expect(find.bySemanticsLabel(AppConstants.downloadAll(2)), findsOneWidget);
  });

  testWidgets('offline, episodes not downloaded are dimmed and disabled',
      (tester) async {
    await pump(tester, page(), offline: true);

    expect(find.text(AppConstants.notDownloaded), findsNWidgets(2));
    expect(find.bySemanticsLabel(AppConstants.notAvailableOffline),
        findsNWidgets(2));
    await tester.tap(find.text(AppConstants.notDownloaded).first);
    await tester.pumpAndSettle();
    expect(player.calls, isNot(contains('play')));
  });

  testWidgets('play pill starts the episode; Play All becomes Pause',
      (tester) async {
    await pump(tester, page());

    await tester.tap(find.text(AppConstants.play).first);
    await tester.pumpAndSettle();
    expect(player.calls, containsAllInOrder(['setAudioSource', 'play']));
    expect(Get.find<AudioPlayerController>().currentMediaItem?.id, '1');

    player.emitState(true, ProcessingState.ready);
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.pause), findsOneWidget);
  });

  testWidgets('download arrow saves the episode for Downloads', (tester) async {
    await pump(tester, page());

    await tester.tap(find.bySemanticsLabel(AppConstants.download).first);
    // File I/O needs real async.
    final downloads = Get.find<DownloadController>();
    for (var i = 0; i < 50 && !downloads.isDownloaded('1'); i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(downloads.isDownloaded('1'), isTrue);
    expect(find.bySemanticsLabel(AppConstants.removeDownload), findsOneWidget);

    await tester.pumpWidget(
        GetMaterialApp(theme: darkTheme, home: const DownloadsPage()));
    await tester.pumpAndSettle();
    // Grouped under its show, with the storage summary on top.
    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('Sabbath Messages'), findsOneWidget);
    expect(find.textContaining('used by AvventoMedia'), findsOneWidget);
    // Storage bar: free space, and the Episodes / Other apps legend.
    expect(find.text('100.0 GB free'), findsOneWidget);
    expect(find.text(AppConstants.otherApps), findsOneWidget);
    // The bar's segments are actually drawn (they once rendered 0px tall).
    final segments = find.descendant(
        of: find.byKey(const ValueKey('storage-bar')),
        matching: find.byType(ColoredBox));
    expect(segments, findsNWidgets(3));
    for (final e in segments.evaluate()) {
      expect(tester.getSize(find.byWidget(e.widget)).height, 6);
    }

    // Edit → select → Delete. The storage bar stays in edit mode.
    await tester.tap(find.text(AppConstants.edit));
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.otherApps), findsOneWidget);
    await tester.tap(find.text('Episode 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 selected'), findsOneWidget);
    await tester.tap(find.text(AppConstants.delete));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(downloads.isDownloaded('1'), isFalse);
    expect(find.text(AppConstants.noDownloads), findsOneWidget);
  });

  testWidgets('Played filter shows only finished downloads', (tester) async {
    await pump(tester, const Scaffold(body: DownloadsView()));
    final downloads = Get.find<DownloadController>();
    downloads.download(episode('1'), showTitle: show.title);
    downloads.download(episode('2'), showTitle: show.title);
    // File I/O needs real async.
    for (var i = 0; i < 100 && downloads.downloads.length < 2; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    Get.find<EpisodeProgressController>().setPlayed('1', true);
    await tester.pumpAndSettle();
    expect(find.text('Episode 2'), findsOneWidget);

    // The chip sits above the list; the played row's pill also says Played.
    await tester.tap(find.text(AppConstants.played).first);
    await tester.pumpAndSettle();
    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('Episode 2'), findsNothing);
  });

  testWidgets('bookmark turns amber once the show is in a playlist',
      (tester) async {
    await pump(tester, page());
    Icon bookmark() => tester.widget<Icon>(find.descendant(
        of: find.bySemanticsLabel(AppConstants.saveToPlaylist),
        matching: find.byType(Icon)));
    expect(bookmark().color, isNot(AvventoColors.dark.accent));

    final library = Get.find<LibraryController>();
    await tester.runAsync(() async {
      final playlist = await library.createPlaylist('Sermons');
      await library.addToPlaylist(
          playlist.id,
          SavedItem(
            id: show.id,
            type: 'podcast_show',
            title: show.title,
            thumbnailUrl: '',
            groupId: show.id,
            groupTitle: show.title,
            savedAt: DateTime.now(),
          ));
    });
    await tester.pumpAndSettle();
    expect(bookmark().color, AvventoColors.dark.accent);
    expect(bookmark().icon, CupertinoIcons.bookmark_fill);
  });

  testWidgets('load failure offers retry', (tester) async {
    await pump(tester, page(fail: true));

    expect(find.text(AppConstants.episodesLoadFailed), findsOneWidget);
    expect(find.text(AppConstants.retry), findsOneWidget);
  });

  testWidgets('light theme keeps titles readable', (tester) async {
    await pump(tester, page(), theme: lightTheme);

    final title = tester.widget<Text>(find.text('Episode 2'));
    expect(title.style!.color, isNot(lightTheme.colorScheme.surface));
    expect(title.style!.color!.computeLuminance(), lessThan(0.2));
  });

  testWidgets('fits a 360dp phone at 130% text in both themes', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    // Long titles must wrap, never overflow.
    final long = PodcastEpisodeListPage(
      fetchEpisodes: (_) async => [
        episode('1',
            title: 'Victory Amidst Troubles Pt. 3: Waiting on God in Prison'),
        episode('2', title: 'Victory Amidst Troubles Pt. 2'),
      ],
    );
    await pump(tester, long);
    expect(tester.takeException(), isNull);
    Get.reset();
    await pump(tester, long, theme: lightTheme);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bible feeds group chapters under pinned book headers',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pump(tester,
        PodcastEpisodeListPage(fetchEpisodes: (_) async => bibleEpisodes()),
        podcast: podcastNamed('Old Testament KJV Dramatized', 5));
    double y(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(find.text(AppConstants.bibleLabel), findsOneWidget);
    expect(find.text(AppConstants.chapterCount(50)), findsOneWidget);
    expect(find.text(AppConstants.chapterCount(40)), findsOneWidget);
    // In order: book, then chapter (episode numbers repeat per book).
    expect(y('Genesis 1'), lessThan(y('Genesis 3')));
    expect(y('Genesis 3'), lessThan(y('Exodus 1')));
    expect(y('Exodus'), lessThan(y('Exodus 1')));
    expect(find.text('CHAPTER 1'), findsNWidgets(2));
    // The book pill shows the first book.
    expect(find.bySemanticsLabel('${AppConstants.jumpToBook}, Genesis'),
        findsWidgets);

    // Newest first drops the grouping.
    await tester.tap(find.text(AppConstants.inOrder));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppConstants.newestFirst));
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.chapterCount(50)), findsNothing);
    expect(y('Exodus 2'), lessThan(y('Genesis 1')));
  });

  testWidgets('book jump scrolls to the book; the pill follows scrolling',
      (tester) async {
    await pump(
        tester,
        PodcastEpisodeListPage(
            fetchEpisodes: (_) async => bibleEpisodes(genesis: 20, exodus: 15)),
        podcast: podcastNamed('Old Testament KJV Dramatized', 35));

    await tester
        .tap(find.bySemanticsLabel('${AppConstants.jumpToBook}, Genesis').first);
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.jumpToBook), findsOneWidget);
    // One testament only: no toggle.
    expect(find.text(AppConstants.newTestament), findsNothing);
    await tester.tap(find.text('Exodus').last);
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.jumpToBook), findsNothing);
    // Exodus's header is pinned at the top, with its first chapter below.
    expect(tester.getTopLeft(find.text('Exodus')).dy, lessThan(40));
    expect(find.text('Exodus 1'), findsOneWidget);
    expect(find.text('Genesis 1'), findsNothing);

    // Mid-scroll, the pinned header opens the book jump too.
    await tester.tap(
        find.bySemanticsLabel('${AppConstants.jumpToBook}, Exodus').first);
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.jumpToBook), findsOneWidget);
    await tester.tap(find.text('Genesis').last);
    await tester.pumpAndSettle();
    expect(find.text('Genesis 1'), findsOneWidget);

    // Scrolling back up hands the pill back to Genesis.
    await tester.fling(
        find.byType(CustomScrollView), const Offset(0, 4000), 3000);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('${AppConstants.jumpToBook}, Genesis'),
        findsWidgets);
  });

  testWidgets('Bible page and book picker fit a 360dp phone at 130% text',
      (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(
        tester,
        PodcastEpisodeListPage(
          fetchEpisodes: (_) async => [
            episode('m1', title: '1 Thessalonians 1', season: 52, number: 1),
            episode('s1', title: 'Song of Solomon 1', season: 22, number: 1),
            ...bibleEpisodes(),
          ],
        ),
        podcast: podcastNamed('Bible', 7));
    expect(tester.takeException(), isNull);

    await tester.tap(
        find.bySemanticsLabel('${AppConstants.jumpToBook}, Genesis').first);
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.newTestament), findsOneWidget);
    await tester.tap(find.text(AppConstants.newTestament));
    await tester.pumpAndSettle();
    expect(find.text('1 Thessalonians'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ellen G. White books list chapters without the book name',
      (tester) async {
    await pump(
        tester,
        PodcastEpisodeListPage(
          fetchEpisodes: (_) async => [
            episode('c2',
                daysAgo: 0,
                title: 'Ch. 2 - The Creation (Patriarchs and Prophets)',
                number: 2),
            episode('c1',
                daysAgo: 1,
                title:
                    'Ch. 1 - Why Was Sin Permitted (Patriarchs and Prophets)',
                number: 1),
          ],
        ),
        podcast: podcastNamed('Patriarchs and Prophets (Dramatized)', 2));
    double y(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(find.text(AppConstants.egwLabel), findsOneWidget);
    // Header meta and the count beside the sort pill.
    expect(find.text(AppConstants.chapterCount(2)), findsNWidgets(2));
    expect(y('Ch. 1 – Why Was Sin Permitted'),
        lessThan(y('Ch. 2 – The Creation')));
    expect(find.text('CHAPTER 1'), findsOneWidget);
    // No summaries on book chapters.
    expect(find.textContaining('About episode'), findsNothing);

    Get.find<EpisodeProgressController>().setPlayed('c1', true);
    await tester.pumpAndSettle();
    expect(find.text(AppConstants.resume), findsOneWidget);
    expect(find.text(AppConstants.chapterShort(2)), findsOneWidget);
  });

  testWidgets('empty Downloads explains how to download', (tester) async {
    await pump(tester, const Scaffold(body: DownloadsView()));

    expect(find.text(AppConstants.noDownloads), findsOneWidget);
    expect(find.text(AppConstants.noDownloadsMessage), findsOneWidget);
  });

  test('time labels', () {
    expect(episodeTimeLabel(const EpisodeProgress()), AppConstants.play);
    expect(
        episodeTimeLabel(
            const EpisodeProgress(duration: Duration(minutes: 48))),
        '48 min');
    expect(
        episodeTimeLabel(const EpisodeProgress(
            position: Duration(minutes: 30), duration: Duration(minutes: 48))),
        '18 min left');
    expect(episodeTimeLabel(const EpisodeProgress(played: true)),
        AppConstants.played);
  });

  test('date labels', () {
    final now = DateTime(2026, 10, 12, 12);
    int ts(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;
    expect(episodeDateLabel(ts(now), now: now), 'TODAY');
    expect(episodeDateLabel(ts(DateTime(2026, 10, 4)), now: now), 'OCT 4');
    expect(episodeDateLabel(ts(DateTime(2024, 3, 1)), now: now), 'MAR 1, 2024');
  });
}
