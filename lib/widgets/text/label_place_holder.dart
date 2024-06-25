import 'package:avvento_media/componets/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LabelPlaceHolder extends StatelessWidget {
  final String title;
  final bool? moreIcon; // Corrected Bool to bool
  final Color? color;
  final VoidCallback? onMoreTap;
  final double titleFontSize;

  const LabelPlaceHolder({
    super.key,
    required this.title,
    this.titleFontSize = 15,
    this.moreIcon,
    this.color,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: AppConstants.leftMain, right: AppConstants.rightMain),
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
          // check for true value
          if (moreIcon != null && moreIcon!)
            GestureDetector(
              onTap: onMoreTap,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
