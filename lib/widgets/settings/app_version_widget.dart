import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionWidget extends StatefulWidget {
  const AppVersionWidget({super.key});

  @override
  AppVersionWidgetState createState() => AppVersionWidgetState();
}

class AppVersionWidgetState extends State<AppVersionWidget> {
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        _appVersion,
        style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }
}
