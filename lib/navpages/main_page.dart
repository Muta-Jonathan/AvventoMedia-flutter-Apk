import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/navpages/home_page.dart';
import 'package:avvento_radio/navpages/listen_page.dart';
import 'package:avvento_radio/navpages/profile_page.dart';
import 'package:avvento_radio/navpages/schedule_page.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List _pages = const [
    HomePage(),
    ListenPage(),
    SchedulePage(),
    ProfilePage()
  ];

  //on tap to go to different screens per index
  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color.fromARGB(255, 22, 20, 36),
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.background,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        elevation: 0,
        //Bottom Navigation Bar with [Home,Listen,Schedule,Profile]
        items: const [
          BottomNavigationBarItem(label: "Home",icon: Icon(CupertinoIcons.house_alt)),
          BottomNavigationBarItem(label: "Listen",icon: Icon(CupertinoIcons.headphones)),
          BottomNavigationBarItem(label: "Schedule",icon: Icon(CupertinoIcons.calendar_today)),
          BottomNavigationBarItem(label: "Profile",icon: Icon(CupertinoIcons.person)),
      ],),
    );
  }
}
