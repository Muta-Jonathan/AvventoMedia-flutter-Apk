import 'package:flutter/material.dart';

/// Expands / collapses a [PlayerPanel] from code.
class PlayerPanelController {
  _PlayerPanelState? _panel;
  bool? _pendingExpand;

  /// Requests made before the panel is mounted apply once it attaches.
  void expand() => _go(true);
  void collapse() => _go(false);

  void _go(bool expand) {
    final panel = _panel;
    if (panel == null) {
      _pendingExpand = expand;
    } else {
      panel._animateTo(expand ? 1 : 0);
    }
  }
}

/// A bottom panel that drags between [minHeight] (mini bar) and [maxHeight]
/// (full player). Replaces the unmaintained `miniplayer` package.
class PlayerPanel extends StatefulWidget {
  const PlayerPanel({
    super.key,
    required this.controller,
    required this.minHeight,
    required this.maxHeight,
    required this.builder,
    this.onChanged,
    this.backgroundColor = const Color(0x70000000),
    this.elevation = 0,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  final PlayerPanelController controller;
  final double minHeight;
  final double maxHeight;

  /// Builds the panel content. [percentage]: 0 collapsed, 1 expanded.
  final Widget Function(double height, double percentage) builder;

  /// Called on every change of the expansion percentage (drag or animation),
  /// never during build.
  final ValueChanged<double>? onChanged;

  /// Barrier behind the expanded panel, faded in with the percentage.
  final Color backgroundColor;
  final double elevation;
  final Duration duration;
  final Curve curve;

  @override
  State<PlayerPanel> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<PlayerPanel>
    with SingleTickerProviderStateMixin {
  /// Above this fling speed (px/s) the direction decides the snap.
  static const _flingVelocity = 700.0;

  late final AnimationController _progress =
      AnimationController(vsync: this, duration: widget.duration)
        ..addListener(() => widget.onChanged?.call(_progress.value));

  double _dragStart = 0;

  double get _range => widget.maxHeight - widget.minHeight;

  @override
  void initState() {
    super.initState();
    _attach(widget.controller);
  }

  @override
  void didUpdateWidget(PlayerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller);
      _attach(widget.controller);
    }
  }

  @override
  void dispose() {
    _detach(widget.controller);
    _progress.dispose();
    super.dispose();
  }

  void _attach(PlayerPanelController controller) {
    controller._panel = this;
    final pending = controller._pendingExpand;
    controller._pendingExpand = null;
    if (pending != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _animateTo(pending ? 1 : 0));
    }
  }

  void _detach(PlayerPanelController controller) {
    if (identical(controller._panel, this)) controller._panel = null;
  }

  void _animateTo(double target) {
    if (!mounted) return;
    final distance = (target - _progress.value).abs();
    if (distance == 0) return;
    _progress.animateTo(
      target,
      duration: widget.duration * distance.clamp(0.4, 1.0),
      curve: widget.curve,
    );
  }

  void _onDragStart(DragStartDetails _) {
    _progress.stop();
    _dragStart = _progress.value;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_range <= 0) return;
    // Up is negative dy; AnimationController clamps to 0..1.
    _progress.value -= details.primaryDelta! / _range;
  }

  void _onDragEnd(DragEndDetails details) {
    final upwardVelocity = -(details.primaryVelocity ?? 0);
    final bool expand;
    if (upwardVelocity.abs() > _flingVelocity) {
      expand = upwardVelocity > 0;
    } else if (_dragStart >= 0.5) {
      // From expanded: collapse once dragged 20 % down.
      expand = _progress.value > 0.8;
    } else {
      // From collapsed: expand once dragged 20 % up.
      expand = _progress.value > 0.2;
    }
    _animateTo(expand ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final canvas = Theme.of(context).canvasColor;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final percentage = _progress.value;
        final height = widget.minHeight + _range * percentage;

        // Both children always present: inserting the barrier mid-drag would
        // shift the panel in the Stack, rebuild its GestureDetector and drop
        // the drag.
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                ignoring: percentage == 0,
                child: GestureDetector(
                  onTap: () => _animateTo(0),
                  child: ColoredBox(
                    color: widget.backgroundColor.withValues(
                        alpha: widget.backgroundColor.a * percentage),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height,
              child: GestureDetector(
                // Vertical only: horizontal gestures (seek bar) stay with
                // the content.
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                onTap: percentage == 0 ? () => _animateTo(1) : null,
                child: Material(
                  color: canvas,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: canvas,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: widget.elevation,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.builder(height, percentage),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
