import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/patreonButton.dart';
import 'package:flutter_donation_buttons/donationButtons/paypalButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../componets/app_constants.dart';
import '../componets/utils.dart';
import '../routes/routes.dart';
import '../widgets/settings/app_version_widget.dart';
import '../widgets/settings/custom_list_tile.dart';
import '../widgets/text/label_place_holder.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body:  CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              floating: true,
              title: const Text(AppConstants.more),
            ),
            SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
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
                  label: AppConstants.youtube,
                  leadingIcon: FontAwesomeIcons.youtube,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.youtubeWebsite, inApp: true),
                ),
                const SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      width: double.infinity,
                      height: Utils.calculateWidth(context, 0.39),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                              const PatreonButton(patreonName:  AppConstants.patreonName),
                              // const PayPalButton(
                              //   paypalButtonId: AppConstants.paypalButtonId,
                              //   color: Colors.orange,
                              // ),
                            ],
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
                  label: AppConstants.previousBroadcasts,
                  leadingIcon: CupertinoIcons.globe,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.previousBroadcastsUrl),
                ),
                CustomListTile(
                  label: AppConstants.avventoRadioTelegram,
                  leadingIcon: Icons.telegram_sharp,
                  isSwitch: false,
                  onTap: () => Utils.openBrowserURL(url: AppConstants.avventoRadioTelegramUrl, inApp: true),
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
                const SizedBox(height: 10,),
                // app version
                const Center(
                  child: AppVersionWidget(),
                ),
                const SizedBox(height: 12,),
                const Divider(),
              ],
            ),
            ),
          ],
        ),
    );
  }
}
