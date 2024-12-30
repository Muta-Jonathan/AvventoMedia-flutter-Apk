import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/ko-fiButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../components/utils.dart';
import '../routes/routes.dart';
import '../widgets/settings/app_creaters_widget.dart';
import '../widgets/settings/app_version_widget.dart';
import '../widgets/settings/custom_list_tile.dart';
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
                const SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      width: double.infinity,
                      height: Utils.calculateHeight(context, 0.21),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextOverlay(label: AppConstants.donateTitle,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: Utils.calculateWidth(context,0.04),
                                ),
                                const Gap(10),
                                TextOverlay(label: AppConstants.donateMessage,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  fontSize: Utils.calculateWidth(context,0.03),
                                  maxLines: 3,
                                ),
                                const Gap(10),
                                const KofiButton(text:AppConstants.kofiText,kofiName: AppConstants.kofiName,kofiColor: KofiColor.Red),
                              ],
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 12,),
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
                  label: AppConstants.instagram,
                  leadingIcon: FontAwesomeIcons.instagram,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.instagramWebsite, inApp: true),
                ),
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
