import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../themes/avvento_colors.dart';

/// Sweeps a soft highlight across its skeleton children every 1.2 seconds.
/// Still when the device asks for reduced motion. Screen readers hear
/// "Loading" once instead of the empty boxes.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  /// One sweep.
  static const period = Duration(milliseconds: 1200);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Shimmer.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final base = c.skeleton;
    final highlight = Color.lerp(base, c.text, 0.12)!;

    return Semantics(
      label: AppConstants.loading,
      container: true,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.3, 0.5, 0.7],
            transform: _Slide(rect.width * (_controller.value * 2 - 1)),
          ).createShader(rect),
          child: child,
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.dx);

  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// A rounded placeholder block (or circle). Put it inside a [Shimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.circle = false,
  });

  /// A circle of [size].
  const SkeletonBox.circle(double size, {Key? key})
      : this(key: key, width: size, height: size, circle: true);

  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).avvento.skeleton,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
