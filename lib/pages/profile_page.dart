import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../components/app_snackbar.dart';
import '../components/utils.dart';
import '../controller/library_controller.dart';
import '../controller/settings_controller.dart';
import '../routes/routes.dart';
import '../widgets/settings/app_creaters_widget.dart';
import '../widgets/settings/app_version_widget.dart';
import '../widgets/settings/donate_bottom_sheet.dart';
import '../widgets/settings/settings_group.dart';

/// Icon-tile colours from the More redesign.
class _Tint {
  static const amber = Color(0xFFFFB300);
  static const red = Color(0xFFFF5252);
  static const blue = Color(0xFF4F8CFF);
  static const green = Color(0xFF3CCF7A);
  static const purple = Color(0xFFA77BFF);
  static const teal = Color(0xFF26C6DA);
  static const pink = Color(0xFFFF6FA8);
  static const grey = Color(0xFF9E9CB0);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();
    final settings = Get.find<SettingsController>();
    final onSurface = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 18),
              child: Text(
                AppConstants.more,
                style: TextStyle(
                    color: onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const _SupportBanner(),

            Obx(() => SettingsGroup(
                  title: AppConstants.myLibrary,
                  tiles: [
                    SettingsTile(
                      icon: CupertinoIcons.heart_fill,
                      color: _Tint.red,
                      label: AppConstants.favorites,
                      badge: library.favoritesCount,
                      onTap: () =>
                          Get.toNamed(Routes.getLibraryFavoritesRoute()),
                    ),
                    SettingsTile(
                      icon: Icons.playlist_play_rounded,
                      color: _Tint.amber,
                      label: AppConstants.myPlaylists,
                      badge: library.playlistsCount,
                      onTap: () =>
                          Get.toNamed(Routes.getLibraryPlaylistsRoute()),
                    ),
                  ],
                )),

            Obx(() => SettingsGroup(
                  title: AppConstants.preferences,
                  tiles: [
                    SettingsTile(
                      icon: CupertinoIcons.moon_fill,
                      color: _Tint.purple,
                      label: AppConstants.darkMode,
                      trailing: SettingsSegmented<ThemeMode>(
                        segments: const {
                          ThemeMode.system: AppConstants.themeAuto,
                          ThemeMode.dark: AppConstants.themeOn,
                          ThemeMode.light: AppConstants.themeOff,
                        },
                        selected: settings.themeMode.value,
                        onChanged: settings.setThemeMode,
                      ),
                    ),
                    SettingsTile(
                      icon: CupertinoIcons.bell_fill,
                      color: _Tint.red,
                      label: AppConstants.allowNotifications,
                      trailing: SettingsSwitch(
                        value: settings.notificationsEnabled.value,
                        onChanged: (on) async {
                          final result =
                              await settings.setNotificationsEnabled(on);
                          if (on && !result) {
                            AppSnackbar.show(AppConstants.notificationsDenied);
                          }
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: CupertinoIcons.rectangle_dock,
                      color: _Tint.teal,
                      label: AppConstants.allowMiniPlayer,
                      trailing: SettingsSwitch(
                        value: settings.miniPlayerEnabled.value,
                        onChanged: settings.setMiniPlayerEnabled,
                      ),
                    ),
                  ],
                )),

            SettingsGroup(
              title: AppConstants.general,
              tiles: [
                SettingsTile(
                  icon: Icons.volunteer_activism,
                  color: _Tint.purple,
                  label: AppConstants.prayerRequest,
                  onTap: () => Get.toNamed(Routes.getPrayerRequestRoute()),
                ),
                SettingsTile(
                  icon: CupertinoIcons.globe,
                  color: _Tint.blue,
                  label: AppConstants.avventoWebsiteTitle,
                  external: true,
                  onTap: () =>
                      Utils.openBrowserURL(url: AppConstants.avventoWebsite),
                ),
                SettingsTile(
                  icon: CupertinoIcons.share,
                  color: _Tint.green,
                  label: AppConstants.shareApp,
                  showChevron: false,
                  onTap: () => Utils.share(
                      "${AppConstants.shareAppMessage} 📱, \n ${AppConstants.shareAppLink}"),
                ),
              ],
            ),

            SettingsGroup(
              title: AppConstants.radio,
              tiles: [
                SettingsTile(
                  icon: Icons.radio,
                  color: _Tint.amber,
                  label: AppConstants.webRadio,
                  external: true,
                  onTap: () =>
                      Utils.openBrowserURL(url: AppConstants.webRadioUrl),
                ),
                SettingsTile(
                  icon: CupertinoIcons.calendar,
                  color: _Tint.teal,
                  label: AppConstants.radioSchedule,
                  external: true,
                  onTap: () =>
                      Utils.openBrowserURL(url: AppConstants.radioScheduleUrl),
                ),
                SettingsTile(
                  icon: CupertinoIcons.mic_fill,
                  color: _Tint.purple,
                  label: AppConstants.podcastBroadcasts,
                  external: true,
                  onTap: () => Utils.openBrowserURL(
                      url: AppConstants.podcastBroadcastsUrl),
                ),
                SettingsTile(
                  icon: Icons.telegram,
                  color: _Tint.blue,
                  label: AppConstants.avventoRadioTelegram,
                  external: true,
                  onTap: () => Utils.openBrowserURL(
                      url: AppConstants.avventoRadioTelegramUrl, inApp: true),
                ),
              ],
            ),

            SettingsGroup(
              title: AppConstants.youtubeChannels,
              tiles: [
                for (final (label, url) in [
                  (
                    AppConstants.avventoYoutubeChannel,
                    AppConstants.avventoYoutubeChannelLink
                  ),
                  (
                    AppConstants.musicYoutubeChannel,
                    AppConstants.musicYoutubeChannelLink
                  ),
                  (
                    AppConstants.kidsYoutubeChannel,
                    AppConstants.kidsYoutubeChannelLink
                  ),
                ])
                  SettingsTile(
                    icon: FontAwesomeIcons.youtube.data,
                    color: _Tint.red,
                    label: label,
                    external: true,
                    onTap: () => Utils.openBrowserURL(url: url, inApp: true),
                  ),
              ],
            ),

            SettingsGroup(
              title: AppConstants.followUs,
              tiles: [
                SettingsTile(
                  icon: FontAwesomeIcons.tiktok.data,
                  color: _Tint.pink,
                  label: AppConstants.tiktok,
                  external: true,
                  onTap: () => Utils.openBrowserURL(
                      url: AppConstants.tiktokWebsite, inApp: true),
                ),
                SettingsTile(
                  icon: FontAwesomeIcons.facebook.data,
                  color: _Tint.blue,
                  label: AppConstants.facebook,
                  external: true,
                  onTap: () => Utils.openBrowserURL(
                      url: AppConstants.facebookWebsite, inApp: true),
                ),
              ],
            ),

            SettingsGroup(
              title: AppConstants.getTheApp,
              tiles: [
                SettingsTile(
                  icon: FontAwesomeIcons.googlePlay.data,
                  color: _Tint.green,
                  label: AppConstants.googlePlayStore,
                  external: true,
                  onTap: () => Utils.openBrowserURL(
                      url: AppConstants.shareAppLinkAndroid, inApp: true),
                ),
                SettingsTile(
                  icon: FontAwesomeIcons.appStoreIos.data,
                  color: _Tint.grey,
                  label: AppConstants.appleAppStore,
                  external: true,
                  onTap: () => Utils.openBrowserURL(
                      url: AppConstants.shareAppLinkIOS, inApp: true),
                ),
              ],
            ),

            SettingsGroup(
              title: AppConstants.supportAndLegal,
              tiles: [
                SettingsTile(
                  icon: CupertinoIcons.flag_fill,
                  color: _Tint.amber,
                  label: AppConstants.report,
                  onTap: Utils.openEmail,
                ),
                SettingsTile(
                  icon: CupertinoIcons.doc_text_fill,
                  color: _Tint.grey,
                  label: AppConstants.termsOfService,
                  external: true,
                  onTap: () =>
                      Utils.openBrowserURL(url: AppConstants.termsUrl),
                ),
                SettingsTile(
                  icon: CupertinoIcons.lock_fill,
                  color: _Tint.grey,
                  label: AppConstants.privacyPolicy,
                  external: true,
                  onTap: () =>
                      Utils.openBrowserURL(url: AppConstants.privacyUrl),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Center(child: AppCreatorsWidget()),
            const SizedBox(height: 12),
            const Center(child: AppVersionWidget()),
          ],
        ),
      ),
    );
  }
}

/// Donation call-to-action at the top of More.
class _SupportBanner extends StatelessWidget {
  const _SupportBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => DonateBottomSheet.show(context),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade800.withValues(alpha: 0.35),
                Colors.red.shade900.withValues(alpha: 0.25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.amber.withValues(alpha: 0.25), width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.favorite_rounded,
                    color: Colors.amber.shade400, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.supportUs,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppConstants.supportUsSubtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  color: Colors.amber.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
