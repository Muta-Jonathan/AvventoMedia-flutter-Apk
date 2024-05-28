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
            statusBarBrightness: Brightness.light,
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
        cursorColor: Colors.orange,
        selectionHandleColor: Colors.orange,
    ),
    textTheme: const TextTheme(
        bodyMedium: TextStyle(
        color: Colors.white, 
        ),
    )
);