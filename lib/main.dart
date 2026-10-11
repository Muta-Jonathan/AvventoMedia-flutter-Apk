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
          routingCallback: (routing) {
            if (routing?.current != null) {
              Get.find<AudioPlayerController>().currentRoute.value =
                  routing!.current;
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

/// Wraps the entire app in a Stack with the Miniplayer panel on top.
///
/// Positioning logic:
///   • On the home route (NavBar visible) the collapsed mini bar sits ABOVE
///     the BottomNavigationBar (offset = navBarHeight when pct = 0).
///   • On any pushed route (no BottomNav) the mini bar anchors flush to the
///     screen bottom (offset = 0).
///   • As the panel expands (pct → 1) the offset smoothly goes to 0 so the
///     full player covers the whole screen in both cases.
class _MiniPlayerOverlay extends StatelessWidget {
  final Widget child;
  const _MiniPlayerOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    final audioCtrl = Get.find<AudioPlayerController>();

    return Obx(() {
      final isActive = audioCtrl.isPlayerActive.value;
      final isVisible = audioCtrl.isMiniPlayerVisible.value;

      // Nothing playing — render the page tree as-is.
      if (!isActive || !isVisible) return child;

      final pct = audioCtrl.panelPercentage.value;
      final screenH = MediaQuery.of(context).size.height;
      final safeBot = MediaQuery.of(context).padding.bottom;

      // BottomNav exists only on the root NavBar route ("/").
      final onHomeRoute = audioCtrl.currentRoute.value == Routes.home ||
          audioCtrl.currentRoute.value == '/';
      final navH = onHomeRoute ? kBottomNavigationBarHeight + safeBot : 0.0;

      // Linearly shrink the bottom inset as the panel expands.
      // Multiply by 4 so the inset reaches 0 by 25 % expansion — the BottomNav
      // fades at the same rate, so there is never an uncovered gap.
      final bottomInset = (navH * (1.0 - pct * 4)).clamp(0.0, navH);

      return Stack(
        children: [
          // Underlying page tree
          child,

          // Miniplayer positioned so that:
          //   collapsed → bottom edge sits just above the BottomNav
          //   expanded  → covers the full screen (bottom = 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            // Height is always the full screen height so the Miniplayer has
            // enough room to animate to its maxHeight. As `bottomInset` goes
            // to 0 the widget shifts down, covering the BottomNav area.
            height: screenH,
            child: Miniplayer(
              controller: audioCtrl.miniplayerController,
              minHeight: miniPlayerMinHeight,
              maxHeight: screenH,
              elevation: 8,
              backgroundColor: Theme.of(context).colorScheme.surface,
              builder: (height, percentage) {
                // Update panelPercentage after the frame to avoid calling
                // setState during build.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  audioCtrl.onPanelPercentageChanged(percentage);
                });

                if (percentage < 0.2) return const MiniPlayerWidget();
                return const FullPlayerWidget();
              },
            ),
          ),
        ],
      );
    });
  }
}
