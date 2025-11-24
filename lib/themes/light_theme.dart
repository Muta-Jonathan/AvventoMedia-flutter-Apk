import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 22, 20, 36),),
    systemOverlayStyle: SystemUiOverlayStyle( //<-- SEE HERE
      // Status bar color
      statusBarColor:  Colors.grey[200]!,
      systemNavigationBarColor: Colors.grey[200]!,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.grey[600]!.withOpacity(0.5),
  ) ,
  colorScheme: ColorScheme.light(
    surface: Colors.grey[200]!,
    primary: Colors.grey[100]!,
    secondary: Colors.grey[350]!,
    onPrimary: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
    onSecondary: Colors.black45,
    onPrimaryContainer:  Colors.white,
    onSecondaryContainer: Colors.grey[400]!,
    onSurface: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
    tertiaryContainer: Colors.grey[600]!.withOpacity(0.5),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.amber,
    selectionHandleColor: Colors.amber,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber, // Button bg color
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
);