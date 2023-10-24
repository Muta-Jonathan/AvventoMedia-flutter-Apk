import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  static const _key = 'notifications';

  static Future<bool> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false; // Default to false if not set
  }

  static Future<void> setNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_key, value);
  }
}