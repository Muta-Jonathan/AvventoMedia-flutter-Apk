import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData darkTheme = ThemeData(
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