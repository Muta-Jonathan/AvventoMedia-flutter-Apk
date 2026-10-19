import 'dart:async';
import 'dart:io';

import 'package:avvento_media/apis/podcast_repository.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/popup_route_observer.dart';
import 'package:avvento_media/controller/settings_controller.dart';
import 'package:avvento_media/firebase_options.dart';
import 'package:avvento_media/routes/routes.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/audio_players/full_player_widget.dart';
import 'package:avvento_media/widgets/audio_players/mini_player_widget.dart';
import 'package:avvento_media/widgets/audio_players/player_panel.dart';
import 'package:avvento_media/widgets/providers/programs_provider.dart';
import 'package:avvento_media/widgets/providers/radio_podcast_provider.dart';
import 'package:avvento_media/widgets/providers/radio_station_provider.dart';
import 'package:avvento_media/widgets/providers/youtube_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'bindings/initial_binding.dart';

late AudioHandler audioHandler;

final popupRouteObserver = PopupRouteObserver();

/// Height of the collapsed mini player bar (content area only)
const double miniPlayerMinHeight = 70.0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Upgrader.clearSavedSettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await Upgrader.clearSavedSettings();
  Get.put(await SettingsController.load(), permanent: true);
  // Podcasts now come from Firestore's offline cache.
  unawaited(PodcastRepository.clearLegacyCache());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgramsProvider>(
          create: (_) => ProgramsProvider(),
        ),
        ChangeNotifierProvider<RadioStationProvider>(
          create: (_) {
            final radio = RadioStationProvider();
            // Song changes reach the player wherever the user is.
            radio.addListener(() {
              final station = radio.radioStation;
              if (station != null && Get.isRegistered<AudioPlayerController>()) {
                Get.find<AudioPlayerController>().syncRadioStation(station);
              }
            });
            return radio;
          },
        ),
        ChangeNotifierProvider<RadioPodcastProvider>(
          create: (_) => RadioPodcastProvider(),
        ),
        ChangeNotifierProvider<YoutubeProvider>(
          create: (_) => YoutubeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      showIgnore: false,
      showLater: true,
      showReleaseNotes: true,
      barrierDismissible: true,
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: GetMaterialApp(
          navigatorKey: Get.key,
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: Get.find<SettingsController>().themeMode.value,
          initialRoute: Routes.getHomeRoute(),
          getPages: Routes.routes,
          initialBinding: InitialBinding(),
          // Keep currentRoute in sync so the overlay can tell whether the
          // BottomNavigationBar is visible (only on the home/NavBar route).
          navigatorObservers: [popupRouteObserver],
          routingCallback: (routing) {
            if (routing?.current != null) {
              Get.find<AudioPlayerController>()
                  .setCurrentRoute(routing!.current);
            }
          },
          // Root-level builder: the player panel sits above ALL routes
          // (tabs, pushed pages, modals) exactly like Spotify / YouTube Music.
          builder: (context, child) {
            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: _MiniPlayerOverlay(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Wraps the entire app in a Stack with the [PlayerPanel] on top.
///
/// Home route: the mini bar sits above the BottomNavigationBar, which reserves
/// space for it. Other routes: the navigator is shrunk by the bar height so
/// pages, dialogs, sheets and snackbars stay above it.
class _MiniPlayerOverlay extends StatelessWidget {
  final Widget child;
  const _MiniPlayerOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    final audioCtrl = Get.find<AudioPlayerController>();

    return Obx(() {
      final mediaQuery = MediaQuery.of(context);
      final showPlayer =
          audioCtrl.isPlayerActive.value && audioCtrl.isMiniPlayerVisible.value;
      final pct = audioCtrl.panelPercentage.value;
      final screenH = mediaQuery.size.height;

      // BottomNav exists only on the root NavBar route ("/").
      final onHomeRoute = audioCtrl.currentRoute.value == Routes.home ||
          audioCtrl.currentRoute.value == '/';
      final navH = onHomeRoute
          ? kBottomNavigationBarHeight + mediaQuery.padding.bottom
          : 0.0;

      // Inset reaches 0 by 25 % expansion, as the BottomNav fades out.
      final bottomInset = (navH * (1.0 - pct * 4)).clamp(0.0, navH);

      // Not needed while the keyboard covers the bar.
      final reserveBelowPages =
          showPlayer && !onHomeRoute && mediaQuery.viewInsets.bottom == 0;

      // Popups on the home route would open under the collapsed bar.
      final hideForPopup =
          onHomeRoute && pct < 0.2 && popupRouteObserver.openPopups.value > 0;

      // Keep the same tree shape whether or not the player shows, so the
      // navigator is never remounted.
      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                bottom: reserveBelowPages ? miniPlayerMinHeight : 0),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: reserveBelowPages,
              child: child,
            ),
          ),
          if (showPlayer)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset,
              // Full screen height so the panel can animate to maxHeight.
              height: screenH,
              child: Visibility(
                visible: !hideForPopup,
                maintainState: true,
                child: PlayerPanel(
                  controller: audioCtrl.panelController,
                  minHeight: miniPlayerMinHeight,
                  maxHeight: screenH,
                  elevation: 8,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onChanged: audioCtrl.onPanelPercentageChanged,
                  builder: (height, percentage) =>
                      _PanelContent(percentage: percentage),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Cross-fades the mini bar into the full player over the first 25 % of the
/// drag. Keys keep each side's state while the other fades in or out.
class _PanelContent extends StatelessWidget {
  final double percentage;
  const _PanelContent({required this.percentage});

  static const _fadeEnd = 0.25;

  @override
  Widget build(BuildContext context) {
    final audioCtrl = Get.find<AudioPlayerController>();
    final t = (percentage / _fadeEnd).clamp(0.0, 1.0);

    return Stack(
      children: [
        if (t < 1)
          KeyedSubtree(
            key: const ValueKey('mini'),
            child: IgnorePointer(
              ignoring: t >= 0.5,
              child: Opacity(
                opacity: 1 - t,
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: miniPlayerMinHeight,
                    child: MiniPlayerWidget(),
                  ),
                ),
              ),
            ),
          ),
        if (t > 0)
          KeyedSubtree(
            key: const ValueKey('full'),
            child: IgnorePointer(
              ignoring: t < 0.5,
              child: Opacity(
                opacity: t,
                // Own ScaffoldMessenger so snackbars from the full player
                // show above it rather than under it on the root Scaffold.
                child: ScaffoldMessenger(
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    // HeroControllerScope.none: the app's HeroController can
                    // only belong to the root Navigator.
                    body: HeroControllerScope.none(
                      // Swallow its NavigationNotifications: with only one
                      // page it reports "can't pop", which on Android 14+
                      // predictive back overrides the root Navigator and makes
                      // Back close the app. Back here is handled by the
                      // expanded panel's LocalHistoryEntry instead.
                      child: NotificationListener<NavigationNotification>(
                        onNotification: (_) => true,
                        child: Navigator(
                          onGenerateRoute: (_) => PageRouteBuilder(
                            pageBuilder: (context, __, ___) {
                              audioCtrl.fullPlayerNavigator =
                                  Navigator.of(context);
                              return const FullPlayerWidget();
                            },
                            transitionDuration: Duration.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
