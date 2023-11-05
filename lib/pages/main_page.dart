import 'package:avvento_media/componets/nav_bar/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    OneSignal.initialize("10eb7e55-4746-4247-9880-ef6a56f92a1e");
  }

  @override
  Widget build(BuildContext context) {
    return const NavBar();
  }
}
