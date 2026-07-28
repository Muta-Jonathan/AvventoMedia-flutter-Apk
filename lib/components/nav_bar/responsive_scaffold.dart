import 'package:avvento_media/components/nav_bar/apple_tv_nav_bar.dart';
import 'package:avvento_media/components/responsive_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<Widget> pages;
  final Widget? miniPlayer;
  final Widget Function(BuildContext context, Widget child)? bodyWrapper;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.pages,
    this.miniPlayer,
    this.bodyWrapper,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.tv) {
          return _buildTvLayout(context);
        } else if (deviceType == DeviceType.tablet) {
          return _buildTabletLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _wrapBody(BuildContext context, Widget child) {
    if (bodyWrapper != null) {
      return bodyWrapper!(context, child);
    }
    return child;
  }

  Widget _buildMobileLayout(BuildContext context) {
    final bodyContent = Stack(
      children: [
        IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        if (miniPlayer != null) miniPlayer!,
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _wrapBody(context, bodyContent),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(label: "Videos", icon: Icon(CupertinoIcons.play_circle)),
          BottomNavigationBarItem(label: "Audio", icon: Icon(CupertinoIcons.headphones)),
          BottomNavigationBarItem(label: "Search", icon: Icon(CupertinoIcons.search)),
          BottomNavigationBarItem(label: "More", icon: Icon(CupertinoIcons.person_crop_circle)),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.onPrimary;

    final bodyContent = Row(
      children: [
        NavigationRail(
          selectedIndex: currentIndex,
          onDestinationSelected: onTabSelected,
          labelType: NavigationRailLabelType.selected,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIconTheme: IconThemeData(color: activeColor),
          unselectedIconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
          selectedLabelTextStyle: TextStyle(color: activeColor, fontWeight: FontWeight.bold),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(CupertinoIcons.play_circle),
              selectedIcon: Icon(CupertinoIcons.play_circle_fill),
              label: Text('Videos'),
            ),
            NavigationRailDestination(
              icon: Icon(CupertinoIcons.headphones),
              selectedIcon: Icon(CupertinoIcons.headphones),
              label: Text('Audio'),
            ),
            NavigationRailDestination(
              icon: Icon(CupertinoIcons.search),
              selectedIcon: Icon(CupertinoIcons.search),
              label: Text('Search'),
            ),
            NavigationRailDestination(
              icon: Icon(CupertinoIcons.person_crop_circle),
              selectedIcon: Icon(CupertinoIcons.person_crop_circle_fill),
              label: Text('More'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Stack(
            children: [
              IndexedStack(
                index: currentIndex,
                children: pages,
              ),
              if (miniPlayer != null) miniPlayer!,
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _wrapBody(context, bodyContent),
    );
  }

  Widget _buildTvLayout(BuildContext context) {
    final bodyContent = Stack(
      children: [
        Positioned.fill(
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: AppleTvNavBar(
            currentIndex: currentIndex,
            onTap: onTabSelected,
          ),
        ),
        if (miniPlayer != null) miniPlayer!,
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _wrapBody(context, bodyContent),
    );
  }
}
