import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A loading placeholder. Shimmers only where real network latency is
/// expected (per the motion policy - no decorative animation) and respects
/// the OS reduced-motion setting by holding a static mid-tone instead.
class RSkeleton extends StatefulWidget {
  const RSkeleton({this.width, this.height = RSpace.s16, this.radius = RRadius.control, super.key});

  final double? width;
  final double height;
  final double radius;

  @override
  State<RSkeleton> createState() => _RSkeletonState();
}

class _RSkeletonState extends State<RSkeleton> with SingleTickerProviderStateMixin {
  // Created in initState, not as a lazy `late final` initialiser - the same
  // fault HeroCarousel had. Under reduced motion build never reads it, so
  // dispose() was its first read, and creating a ticker while the element is
  // deactivating throws.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.outline;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget shape(double opacity) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      );
    }

    if (reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
      return shape(0.5);
    }

    if (!_controller.isAnimating) _controller.repeat(reverse: true);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => shape(0.3 + (_controller.value * 0.3)),
    );
  }
}
