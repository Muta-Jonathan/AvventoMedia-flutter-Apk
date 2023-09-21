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
        secondary: Colors.grey[800]!,
        onPrimary: Colors.white,
        onPrimaryContainer:  Colors.white,
        onSecondaryContainer: Colors.grey[400]!,
        onBackground: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255),
    ),
);