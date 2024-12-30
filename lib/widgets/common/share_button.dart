import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../text/text_overlay_widget.dart';

class ShareButton extends StatelessWidget {
  final VoidCallback? onShareTap;
  const ShareButton({super.key, required this.onShareTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: GestureDetector(
        onTap: onShareTap,
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(CupertinoIcons.share, size: 18,),
              TextOverlay(label: AppConstants.share,
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
