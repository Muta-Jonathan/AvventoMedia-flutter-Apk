import 'package:flutter/cupertino.dart';

class BoxedIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double borderRadius;
  final double iconSize;
  final Color backgroundColor;

  const BoxedIcon({
    Key? key,
    this.icon = CupertinoIcons.mic,
    this.iconColor = const Color.fromARGB(255, 22, 20, 36),
    this.borderRadius = 5.0,
    this.iconSize = 20.5,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
