import 'package:flutter/cupertino.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../componets/app_constants.dart';
import '../custom_list_tile.dart';
import 'notification_widget.dart';

class NotificationToggleWidget extends StatefulWidget {
  const NotificationToggleWidget({super.key});

  @override
  _NotificationToggleWidgetState createState() => _NotificationToggleWidgetState();
}

class _NotificationToggleWidgetState extends State<NotificationToggleWidget> {
  bool _isSwitchOn = false; // Change this to false to initially disable custom notifications

  @override
  void initState() {
    super.initState();
    NotificationPreferences.getNotificationPreference().then((value) {
      setState(() {
        _isSwitchOn = value;
      });
    });
  }

  void _handleSwitchChanged(bool value) {
    setState(() {
      _isSwitchOn = value;
    });

    // Update the notification channel when the switch is toggled
    if (value) {
      JustAudioBackground.init(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio', // Disable notifications
        androidNotificationChannelName: '', // Disable notifications
      );
    } else {
      JustAudioBackground.init(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
        androidNotificationChannelName: 'Audio playback2',
        androidNotificationOngoing: true,
      );
    }

    NotificationPreferences.setNotificationPreference(value);
  }

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      label: AppConstants.notifications,
      leadingIcon: CupertinoIcons.bubble_left_bubble_right,
      isSwitch: true,
      onSwitchChanged: _handleSwitchChanged,
    );
  }
}