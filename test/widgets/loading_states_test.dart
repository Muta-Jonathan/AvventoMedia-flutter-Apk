import 'dart:async';

import 'package:avvento_media/apis/presenter_repository.dart';
import 'package:avvento_media/apis/schedule_repository.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/connectivity_controller.dart';
import 'package:avvento_media/controller/presenters_controller.dart';
import 'package:avvento_media/controller/schedule_controller.dart';
import 'package:avvento_media/models/presenter_model.dart';
import 'package:avvento_media/models/schedule_slot.dart';
import 'package:avvento_media/pages/presenter_page.dart';
import 'package:avvento_media/pages/presenters_page.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/common/shimmer.dart';
import 'package:avvento_media/widgets/common/skeletons.dart';
import 'package:avvento_media/widgets/listen/live_hero_card.dart';
import 'package:avvento_media/widgets/listen/podcast_rails.dart';
import 'package:avvento_media/widgets/listen/up_next_strip.dart';
import 'package:avvento_media/widgets/presenters/presenters_rail.dart';
import 'package:avvento_media/widgets/providers/radio_podcast_provider.dart';
import 'package:avvento_media/widgets/providers/radio_station_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

/// Never answers: keeps a screen in its loading state.
class _Pending implements ScheduleRepository, PresenterRepository {
  @override
  Future<List<ScheduleSlot>> fetchSlots() =>
      Completer<List<ScheduleSlot>>().future;
  @override
  Future<List<Presenter>> fetchPresenters() =>
      Completer<List<Presenter>>().future;
  @override
  Future<Presenter> fetchPresenter(String id) => Completer<Presenter>().future;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> show(WidgetTester tester, Widget child,
      {bool reduceMotion = false}) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<RadioPodcastProvider>(
            create: (_) => RadioPodcastProvider()),
        ChangeNotifierProvider<RadioStationProvider>(
            create: (_) => RadioStationProvider.fixed(null)),
      ],
      child: GetMaterialApp(
        theme: darkTheme,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: child!),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ));
    await tester.pump();
  }

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    Get.deleteAll(force: true);
    Get.reset();
  }

  group('Shimmer', () {
    testWidgets('sweeps over 1.2 seconds, and says Loading', (tester) async {
      final handle = tester.ensureSemantics();
      await show(tester, const Shimmer(child: SkeletonBox(height: 20)));

      expect(Shimmer.period, const Duration(milliseconds: 1200));
      expect(tester.hasRunningAnimations, isTrue);
      expect(find.bySemanticsLabel(AppConstants.loading), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      handle.dispose();
    });

    testWidgets('stands still when the device asks for less motion',
        (tester) async {
      await show(tester, const Shimmer(child: SkeletonBox(height: 20)),
          reduceMotion: true);

      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the old spinner widget is a shimmering block now',
        (tester) async {
      await show(tester, const SizedBox(height: 90, child: LoadingWidget()));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Shimmer), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Listen sections', () {
    testWidgets('podcasts show a skeleton until the first fetch finishes',
        (tester) async {
      await show(tester, const PodcastRails());
      expect(find.byType(PodcastRailsSkeleton), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the live card shows a skeleton until the station arrives',
        (tester) async {
      Get.put(AudioPlayerController(
          player: FakeAudioPlayer(), startAudioService: false));
      Get.put(ConnectivityController(
          changes: const Stream.empty(), check: () async => []));
      await show(tester, const LiveHeroCard());

      expect(find.byType(SkeletonBox), findsWidgets);
      expect(find.text(AppConstants.liveBadge), findsNothing);
      await leave(tester);
    });

    testWidgets('Up next shows a skeleton until the schedule arrives',
        (tester) async {
      Get.put(ScheduleController(repository: _Pending()));
      await show(tester, const UpNextStrip());

      expect(find.byType(UpNextSkeleton), findsOneWidget);
      expect(find.text(AppConstants.upNext), findsOneWidget);
      await leave(tester);
    });

    testWidgets('presenters show a skeleton until they load', (tester) async {
      Get.put(PresentersController(repository: _Pending()));
      await show(tester, const PresentersRail());

      expect(find.byType(PresentersRailSkeleton), findsOneWidget);
      await leave(tester);
    });
  });

  group('presenter screens', () {
    testWidgets('the list shows row skeletons under the search',
        (tester) async {
      Get.put(PresentersController(repository: _Pending()));
      await tester.pumpWidget(
          GetMaterialApp(theme: darkTheme, home: const PresentersPage()));
      await tester.pump();

      expect(find.byType(PresenterRowsSkeleton), findsOneWidget);
      expect(find.text(AppConstants.presenters), findsOneWidget);
      await leave(tester);
    });

    testWidgets('a presenter page keeps Back while it loads', (tester) async {
      await tester.pumpWidget(GetMaterialApp(
          theme: darkTheme,
          home: PresenterPage(
              presenterId: 'x', fetch: (_) => Completer<Presenter>().future)));
      await tester.pump();

      expect(find.byType(PresenterPageSkeleton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      await leave(tester);
    });
  });
}
