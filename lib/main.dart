import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/routes/routes.dart';
import 'package:avvento_radio/themes/dark_theme.dart';
import 'package:avvento_radio/themes/light_theme.dart';
import 'package:avvento_radio/widgets/providers/programs_provider.dart';
import 'package:avvento_radio/widgets/providers/spreaker_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'controller/episode_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (context) => ProgramsProvider(),
        ),
        ChangeNotifierProvider<SpreakerEpisodeProvider>(
          create: (context) => SpreakerEpisodeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    );
  }
}
