import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
        elevation: 0,
    ),
    iconTheme: IconThemeData(
        color: Colors.grey.withOpacity(0.5),
    ) ,
    colorScheme: ColorScheme.dark(
        background: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
        primary: Colors.grey[900]!,
        secondary:const Color.fromARGB(255, 46, 44, 61),//rgba(46,44,61,255)
        onPrimary: Colors.white,
        onSecondary: Colors.grey[400]!,
        onPrimaryContainer:  Colors.white,
        onSecondaryContainer: Colors.grey[400]!,
        onBackground: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255),
    ),
);