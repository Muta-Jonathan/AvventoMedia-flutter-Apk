import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class IconButtonBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const IconButtonBox({
    Key? key,
    this.icon = CupertinoIcons.mic,
    this.iconColor = const Color.fromARGB(255, 22, 20, 36),
    this.iconSize = 20.5,
    required this.backgroundColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Make Material widget transparent
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(iconSize / 2), // Half of the button size
        child: Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: backgroundColor, // Background color with some opacity
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize * 0.5,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

