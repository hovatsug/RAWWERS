import 'package:flutter/material.dart';
import '../tokens.dart';

class RSkeleton extends StatefulWidget {
  const RSkeleton({super.key, this.height = 16, this.width = double.infinity, this.borderRadius = RTokens.radiusXl});

  final double height;
  final double width;
  final double borderRadius;

  @override
  State<RSkeleton> createState() => _RSkeletonState();
}

class _RSkeletonState extends State<RSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final opacity = 0.30 + (_controller.value * 0.20);
        return Opacity(
          opacity: opacity,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: RTokens.glassCardBgHover,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: RTokens.glassCardBorder, width: 1),
            ),
          ),
        );
      },
    );
  }
}
