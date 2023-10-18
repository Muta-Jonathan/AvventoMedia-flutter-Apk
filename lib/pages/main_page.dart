import 'package:avvento_radio/componets/nav_bar/nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return const NavBar();
  }
}
