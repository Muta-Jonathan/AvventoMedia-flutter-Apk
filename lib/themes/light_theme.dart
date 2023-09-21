import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Color.fromARGB(255, 22, 20, 36),),

  ),
  iconTheme: IconThemeData(
    color: Colors.grey[600]!.withOpacity(0.5),
  ) ,
  colorScheme: ColorScheme.light(
    background: Colors.grey[200]!,
    primary: Colors.grey[100]!,
    secondary: Colors.grey[200]!,
    onPrimary: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
    onSecondary: Colors.black45,
    onPrimaryContainer:  Colors.white,
    onSecondaryContainer: Colors.grey[400]!,
    onBackground: const Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255)
  ),
);