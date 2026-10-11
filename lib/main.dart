import 'dart:io';

import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/firebase_options.dart';
import 'package:avvento_media/routes/routes.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/audio_players/full_player_widget.dart';
import 'package:avvento_media/widgets/audio_players/mini_player_widget.dart';
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
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'bindings/initial_binding.dart';

late AudioHandler audioHandler;

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgramsProvider>(
          create: (_) => ProgramsProvider(),
        ),
        ChangeNotifierProvider<RadioStationProvider>(
          create: (_) => RadioStationProvider(),
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
          // Root-level builder: the Miniplayer sits above ALL routes
          // (tabs, pushed pages, modals) exactly like Spotify / YouTube Music.
          builder: (context, child) {
            return _MiniPlayerOverlay(
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

/// Counts open dialogs / bottom sheets on the root navigator.
class PopupRouteObserver extends NavigatorObserver {
  final RxInt openPopups = 0.obs;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PopupRoute) runOutsideBuild(() => openPopups.value++);
  }

  @override
  void didPop(Route route, Route? previousRoute) => _closed(route);

  @override
  void didRemove(Route route, Route? previousRoute) => _closed(route);

  void _closed(Route route) {
    if (route is! PopupRoute) return;
    runOutsideBuild(() {
      if (openPopups.value > 0) openPopups.value--;
    });
  }
}

final popupRouteObserver = PopupRouteObserver();

/// Wraps the entire app in a Stack with the Miniplayer panel on top.
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
              // Full screen height so the Miniplayer can animate to maxHeight.
              height: screenH,
              child: Visibility(
                visible: !hideForPopup,
                maintainState: true,
                child: Miniplayer(
                  controller: audioCtrl.miniplayerController,
                  minHeight: miniPlayerMinHeight,
                  maxHeight: screenH,
                  elevation: 8,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (height, percentage) {
                    // Update after the frame to avoid setState during build.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      audioCtrl.onPanelPercentageChanged(percentage);
                    });

                    if (percentage < 0.2) return const MiniPlayerWidget();
                    // No GlobalKey: the miniplayer reparents this subtree
                    // on drag-down, which trips GlobalKey assertions.
                    // HeroControllerScope.none: the app's HeroController
                    // can only belong to the root Navigator.
                    return HeroControllerScope.none(
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
                    );
                  },
                ),
              ),
            ),
        ],
      );
    });
  }
}
