import 'package:flutter/material.dart';

import 'shimmer.dart';

/// A shimmering placeholder block in place of a spinner: it fills the space
/// it is given (up to 320 x 160), or is 200 x 160 when unbounded. Screens that
/// know their layout use real skeletons instead (see skeletons.dart).
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.hasBoundedWidth
          ? constraints.maxWidth.clamp(0.0, 320.0)
          : 200.0;
      final height = constraints.hasBoundedHeight
          ? constraints.maxHeight.clamp(0.0, 160.0)
          : 160.0;
      return Center(
        child: Shimmer(
          child: SkeletonBox(width: width, height: height, radius: 12),
        ),
      );
    });
  }
}
