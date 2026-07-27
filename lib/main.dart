import 'dart:io';

import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/firebase_options.dart';
import 'package:avvento_media/routes/routes.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
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
import 'widgets/audio_players/mini_player_widget.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Lock the app to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  // clear upgrader settings
  await Upgrader.clearSavedSettings();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load .env file
  await dotenv.load(fileName: ".env");

  // We will initialize AudioService inside AudioPlayerController or after creating the player
  // But actually we need the AudioPlayer to pass to the handler.
  // We'll initialize it in AudioPlayerController and register the handler there.

  // Clear upgrader settings
  await Upgrader.clearSavedSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgramsProvider>(
        create: (context) => ProgramsProvider(),
        ),
        ChangeNotifierProvider<RadioStationProvider>(
            create: (context) => RadioStationProvider(),
        ),
        ChangeNotifierProvider<RadioPodcastProvider>(
          create: (context) => RadioPodcastProvider(),
        ),
        ChangeNotifierProvider<YoutubeProvider>(
          create: (context) => YoutubeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  //DependencyInjection.init();
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      showIgnore: false,
      showLater: true,
      showReleaseNotes: true,
      barrierDismissible: true,
      dialogStyle: Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: GetMaterialApp( // Use GetMaterialApp instead of MaterialApp
          navigatorKey: Get.key,
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: lightTheme,
          darkTheme: darkTheme,
          initialRoute: Routes.getHomeRoute(), // Set the initial route to '/'
          getPages: Routes.routes,
          initialBinding: InitialBinding(),
          builder: (context, child) {
            return Stack(
              children: [
                // The actual page content
                child ?? const SizedBox.shrink(),
                // Floating mini player
                const MiniPlayerWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
