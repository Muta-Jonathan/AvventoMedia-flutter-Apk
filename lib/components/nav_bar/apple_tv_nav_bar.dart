import 'dart:ui';
import 'package:avvento_media/components/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppleTvNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppleTvNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'label': 'Videos', 'icon': CupertinoIcons.play_circle_fill},
      {'label': 'Audio', 'icon': CupertinoIcons.headphones},
      {'label': 'Search', 'icon': CupertinoIcons.search},
      {'label': 'More', 'icon': CupertinoIcons.person_crop_circle},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 32, right: 32),
      height: 64,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.65),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Brand Icon
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icon/icon.png',
                          height: 28,
                          width: 28,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            CupertinoIcons.tv_fill,
                            color: Colors.amber,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nav Items
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(navItems.length, (index) {
                      final isSelected = index == currentIndex;
                      final item = navItems[index];

                      return AppleTvNavItem(
                        label: item['label'] as String,
                        icon: item['icon'] as IconData,
                        isSelected: isSelected,
                        onTap: () => onTap(index),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppleTvNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const AppleTvNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AppleTvNavItem> createState() => _AppleTvNavItemState();
}

class _AppleTvNavItemState extends State<AppleTvNavItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.onPrimary;
    final inactiveColor = activeColor.withOpacity(0.6);

    return Focus(
      onFocusChange: (focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isFocused = true),
          onExit: (_) => setState(() => _isFocused = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? activeColor.withOpacity(0.2)
                  : (_isFocused ? Colors.white.withOpacity(0.12) : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
              border: _isFocused
                  ? Border.all(color: activeColor.withOpacity(0.8), width: 1.5)
                  : Border.all(color: Colors.transparent, width: 1.5),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            transform: _isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
            transformAlignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isSelected || _isFocused ? activeColor : inactiveColor,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: widget.isSelected || _isFocused ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isSelected || _isFocused ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
