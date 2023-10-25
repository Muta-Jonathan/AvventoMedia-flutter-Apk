import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData? _themeData;

  ThemeData get themeData => _themeData ?? lightTheme;

  ThemeProvider() {
    _loadThemeMode(); // Load the saved theme mode when the provider is created
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode');
    if (savedThemeMode == 'light') {
      _themeData = lightTheme;
    } else {
      _themeData = darkTheme;
    }
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = _themeData?.brightness.name;
    prefs.setString('themeMode', themeModeString!);
  }

  void toggleTheme() {
    _themeData = _themeData == lightTheme ? darkTheme : lightTheme;
    _saveThemeMode();
    notifyListeners();
  }

}
