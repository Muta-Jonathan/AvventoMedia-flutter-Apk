import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'avvento_colors.dart';

ThemeData darkTheme = ThemeData(
  extensions: const [AvventoColors.dark],
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle( //<-- SEE HERE
            // Status bar color
            statusBarColor: Color.fromARGB(255, 22, 20, 36),
            systemNavigationBarColor: Color.fromARGB(255, 22, 20, 36),//rgba(22,20,36,255)
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
        ),
    ),
    iconTheme: IconThemeData(
        color: Colors.grey.withOpacity(0.5),
    ) ,
    colorScheme: ColorScheme.dark(
        surface: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
        primary: Colors.grey[900]!,
        secondary:const Color.fromARGB(255, 46, 44, 61),//rgba(46,44,61,255)
        onPrimary: Colors.white,
        onSecondary: Colors.grey[400]!,
        onPrimaryContainer:  Colors.white,
        onSecondaryContainer: Colors.grey[400]!,
        onSurface: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255),
        tertiaryContainer: Colors.grey.withOpacity(0.5),
        // Playback accent (play buttons, now-playing highlights)
        tertiary: Colors.orange,
        onTertiary: Colors.black,
    ),
    // Material 3 snackbars: inverse of the surface, floating.
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFFE6E1E5),
      contentTextStyle: TextStyle(color: Color(0xFF1C1B1F), fontSize: 14),
      actionTextColor: Color(0xFFE65100),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
    ),
    textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.amber,
        selectionHandleColor: Colors.amber,
    ),
    textTheme: const TextTheme(
        bodyMedium: TextStyle(
            color: Colors.white,
        ),
    ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber, // Button background
      foregroundColor: Colors.black, // Text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.amber, // Text color
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.amber),
      foregroundColor: Colors.amber,
    ),
  ),
);