import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../components/utils.dart';
import '../controller/library_controller.dart';
import '../routes/routes.dart';
import '../widgets/settings/app_creaters_widget.dart';
import '../widgets/settings/app_version_widget.dart';
import '../widgets/settings/custom_list_tile.dart';
import '../widgets/settings/donate_bottom_sheet.dart';
import '../widgets/text/label_place_holder.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body:  CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor:   Theme.of(context).colorScheme.surface,
              floating: true,
              title: Text(AppConstants.more,style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary
              ),),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            ),
            SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                // MY LIBRARY section
                LabelPlaceHolder(title: AppConstants.myLibrary, color: Theme.of(context).colorScheme.onSecondaryContainer),
                Obx(() {
                  final library = Get.find<LibraryController>();
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(CupertinoIcons.heart, size: 28, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        title: Text(AppConstants.favorites, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 14)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (library.favoritesCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${library.favoritesCount}',
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Icon(CupertinoIcons.chevron_forward, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 18),
                          ],
                        ),
                        onTap: () => Get.toNamed(Routes.getLibraryFavoritesRoute()),
                      ),
                      ListTile(
                        leading: Icon(Icons.playlist_play, size: 28, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        title: Text(AppConstants.myPlaylists, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 14)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (library.playlistsCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${library.playlistsCount}',
                                  style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Icon(CupertinoIcons.chevron_forward, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 18),
                          ],
                        ),
                        onTap: () => Get.toNamed(Routes.getLibraryPlaylistsRoute()),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                // General section
                LabelPlaceHolder(title: AppConstants.general, color: Theme.of(context).colorScheme.onSecondaryContainer),
                CustomListTile(
                  label: AppConstants.prayerRequest,
                  leadingIcon: CupertinoIcons.group,
                  isSwitch: false,
                  onTap: () => Get.toNamed(Routes.getPrayerRequestRoute()),
                ),
                CustomListTile(
                  label: AppConstants.avventoWebsiteTitle,
                  leadingIcon: CupertinoIcons.globe,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.avventoWebsite),
                ),
                CustomListTile(
                  label: AppConstants.avventoYoutubeChannel,
                  leadingIcon: FontAwesomeIcons.youtube,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.avventoYoutubeChannelLink, inApp: true),
                ),
                const SizedBox(height: 12,),
                CustomListTile(
                  label: AppConstants.shareApp,
                  leadingIcon: FontAwesomeIcons.shareFromSquare,
                  isSwitch: false,
                  onTap: () => Utils.share("${AppConstants.shareAppMessage} 📱, \n ${AppConstants.shareAppLink}"),
                ),
                const SizedBox(height: 35,),
                // App Stores section
                LabelPlaceHolder(title: AppConstants.appStores, color: Theme.of(context).colorScheme.onSecondaryContainer),
                CustomListTile(
                  label: AppConstants.playStore,
                  leadingIcon: FontAwesomeIcons.googlePlay,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.shareAppLinkAndroid, inApp: true),
                ),
                CustomListTile(
                  label: AppConstants.appStore,
                  leadingIcon: FontAwesomeIcons.appStoreIos,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.shareAppLinkIOS, inApp: true),
                ),
                const SizedBox(height: 24,),
                // Support section — highlighted banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.leftMain),
                  child: GestureDetector(
                    onTap: () => DonateBottomSheet.show(context),
                    child: Container(
                      width: double.infinity,
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
                          color: Colors.amber.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.amber.shade400,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppConstants.donateTitle,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to see donation options',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: Colors.amber.shade400,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35,),
                // radio section
                LabelPlaceHolder(title: AppConstants.radio, color: Theme.of(context).colorScheme.onSecondaryContainer),
                CustomListTile(
                  label: AppConstants.webRadio,
                  leadingIcon: CupertinoIcons.globe,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.webRadioUrl),
                ),
                CustomListTile(
                  label: AppConstants.radioSchedule,
                  leadingIcon: CupertinoIcons.calendar_today,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.radioScheduleUrl),
                ),
                CustomListTile(
                  label: AppConstants.podcastBroadcasts,
                  leadingIcon: CupertinoIcons.globe,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.podcastBroadcastsUrl),
                ),
                CustomListTile(
                  label: AppConstants.avventoRadioTelegram,
                  leadingIcon: Icons.telegram_sharp,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.avventoRadioTelegramUrl, inApp: true),
                ),
                const SizedBox(height: 35,),
                LabelPlaceHolder(title: AppConstants.youtubeChannels, color: Theme.of(context).colorScheme.onSecondaryContainer),
                CustomListTile(
                  label: AppConstants.avventoYoutubeChannel,
                  leadingIcon: FontAwesomeIcons.youtube,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.avventoYoutubeChannelLink, inApp: true),
                ),
                CustomListTile(
                  label: AppConstants.musicYoutubeChannel,
                  leadingIcon: FontAwesomeIcons.youtube,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.musicYoutubeChannelLink, inApp: true),
                ),
                CustomListTile(
                  label: AppConstants.kidsYoutubeChannel,
                  leadingIcon: FontAwesomeIcons.youtube,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.kidsYoutubeChannelLink, inApp: true),
                ),
                const SizedBox(height: 35,),
                // Social media section
                LabelPlaceHolder(title: AppConstants.socialMedia, color: Theme.of(context).colorScheme.onSecondaryContainer),
                CustomListTile(
                  label: AppConstants.tiktok,
                  leadingIcon: FontAwesomeIcons.tiktok,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.tiktokWebsite, inApp: true),
                ),
                CustomListTile(
                  label: AppConstants.facebook,
                  leadingIcon: FontAwesomeIcons.facebook,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.facebookWebsite, inApp: true),
                ),
                const SizedBox(height: 35,),
                // Feedback section
                LabelPlaceHolder(title: AppConstants.feedBack, color: Theme.of(context).colorScheme.onSecondaryContainer),
                CustomListTile(
                  label: AppConstants.report,
                  leadingIcon: CupertinoIcons.flag,
                  isSwitch: false,
                  onTap: () => Utils.openEmail(),
                ),
                const SizedBox(height: 20,),

                const SizedBox(height: 10,),
                //app_creaters
                const Center(
                  child: AppCreatorsWidget(),
                ),
                const SizedBox(height: 12,),
                // app version
                const Center(
                  child: AppVersionWidget(),
                ),
                const SizedBox(height: 12,),
              ],
            ),
            ),
          ],
        ),
    );
  }
}
