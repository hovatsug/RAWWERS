import 'package:flutter/material.dart';

class RSkeleton extends StatefulWidget {
  const RSkeleton({super.key, this.height = 16, this.width = double.infinity, this.borderRadius = 8});

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
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
        final opacity = 0.45 + (_controller.value * 0.25);
        return Opacity(
          opacity: opacity,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
