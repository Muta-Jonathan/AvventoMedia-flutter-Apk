import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../text/text_overlay_widget.dart';

class ComingSoonDialog extends StatelessWidget {
  final Animation<double> animation;
  const ComingSoonDialog({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5,end: 1.0).animate(animation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.5,end: 1.0).animate(animation),
        child: AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: SizedBox(
            height: 120,
            child: Center(
              child: Lottie.asset('assets/animations/comingSoon.json'),
            ),
          ),
          content: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: TextOverlay(
              label: "Ok, Thanks!",
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
            ),
          ),
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }
}