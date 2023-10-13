import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/firebase_options.dart';
import 'package:avvento_radio/routes/routes.dart';
import 'package:avvento_radio/themes/dark_theme.dart';
import 'package:avvento_radio/themes/light_theme.dart';
import 'package:avvento_radio/widgets/providers/programs_provider.dart';
import 'package:avvento_radio/widgets/providers/radio_station_provider.dart';
import 'package:avvento_radio/widgets/providers/spreaker_data_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'bindings/initial_binding.dart';
import 'controller/episode_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (context) => ProgramsProvider(),
        ),
        ChangeNotifierProvider<SpreakerEpisodeProvider>(
          create: (context) => SpreakerEpisodeProvider(),
        ),
        ChangeNotifierProvider(

            create: (context) => RadioStationProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Bind the EpisodeController to the app
    Get.put(EpisodeController());
    return GetMaterialApp( // Use GetMaterialApp instead of MaterialApp
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: Routes.getHomeRoute(), // Set the initial route to '/'
      getPages: Routes.routes,
      initialBinding: InitialBinding(),
    );
  }
}
