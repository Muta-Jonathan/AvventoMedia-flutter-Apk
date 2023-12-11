import 'package:flutter/material.dart';

class LabelPlaceHolder extends StatelessWidget {
  final String title;
  final String moreLabel;
  final Color? color;
  final VoidCallback? onMoreTap;
  final double titleFontSize;
  const LabelPlaceHolder({super.key, required this.title, this.titleFontSize = 15, this.moreLabel='', this.color, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: titleFontSize,
                  color: color ?? Theme.of(context).colorScheme.onPrimary
              ),
            ),
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: Text(moreLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange
              ),
            ),
          ),
        ],)
      );
  }
}
