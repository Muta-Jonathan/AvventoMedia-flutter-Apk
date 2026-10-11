import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Push opt-in, behind an interface so tests don't need OneSignal.
abstract class PushNotifications {
  bool get enabled;

  /// Asks for permission if needed; false if the user declined.
  Future<bool> enable();
  Future<void> disable();
}

class OneSignalPushNotifications implements PushNotifications {
  @override
  bool get enabled =>
      OneSignal.Notifications.permission &&
      (OneSignal.User.pushSubscription.optedIn ?? false);

  @override
  Future<bool> enable() async {
    if (!OneSignal.Notifications.permission) {
      // fallbackToSettings: opens system settings if previously denied.
      final granted = await OneSignal.Notifications.requestPermission(true);
      if (!granted) return false;
    }
    await OneSignal.User.pushSubscription.optIn();
    return true;
  }

  @override
  Future<void> disable() => OneSignal.User.pushSubscription.optOut();
}

/// User preferences from the More tab, persisted in SharedPreferences.
class SettingsController extends GetxController {
  SettingsController(this._prefs, {PushNotifications? push})
      : _push = push ?? OneSignalPushNotifications();

  static const _themeKey = 'settings_theme_mode';
  static const _miniPlayerKey = 'settings_mini_player';

  final SharedPreferences _prefs;
  final PushNotifications _push;

  late final Rx<ThemeMode> themeMode = ThemeMode.values
      .byName(_prefs.getString(_themeKey) ?? ThemeMode.system.name)
      .obs;
  late final RxBool miniPlayerEnabled =
      (_prefs.getBool(_miniPlayerKey) ?? true).obs;

  /// Mirrors OneSignal; call [refreshNotifications] once it's initialised.
  final RxBool notificationsEnabled = false.obs;

  /// Loaded before runApp so the saved theme applies on the first frame.
  static Future<SettingsController> load({PushNotifications? push}) async =>
      SettingsController(await SharedPreferences.getInstance(), push: push);

  void refreshNotifications() => notificationsEnabled.value = _push.enabled;

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setMiniPlayerEnabled(bool enabled) async {
    miniPlayerEnabled.value = enabled;
    await _prefs.setBool(_miniPlayerKey, enabled);
  }

  /// Returns the resulting state (stays off if permission is declined).
  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      notificationsEnabled.value = await _push.enable();
    } else {
      await _push.disable();
      notificationsEnabled.value = false;
    }
    return notificationsEnabled.value;
  }
}
