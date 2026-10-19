import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Four small bars; they move while [playing] (unless the device asks for
/// reduced motion).
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({super.key, required this.color, required this.playing});

  final Color color;
  final bool playing;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  static const _rest = [6.0, 13.0, 9.0, 12.0];
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(EqualizerBars old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final animate = widget.playing && !MediaQuery.of(context).disableAnimations;
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => SizedBox(
          height: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _rest.length; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Container(
                  width: 3,
                  height: _controller.isAnimating
                      ? 4 +
                          10 *
                              (0.5 +
                                  0.5 *
                                      math.sin(_controller.value * 2 * math.pi +
                                          i * 1.7))
                      : _rest[i],
                  decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(1)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
