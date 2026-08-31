import 'dart:ui';
import 'package:flutter/material.dart';

enum RGlowOrbsVariant { defaultOrbs, dashboard, discovery }

/// Renders blurred colour orbs as a fixed background layer.
/// Place as the first child of a [Stack] so glass cards above pick up the blur.
class RGlowOrbs extends StatelessWidget {
  const RGlowOrbs({super.key, this.variant = RGlowOrbsVariant.defaultOrbs});

  final RGlowOrbsVariant variant;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(children: _orbs()),
      ),
    );
  }

  List<Widget> _orbs() {
    switch (variant) {
      case RGlowOrbsVariant.dashboard:
        return [
          _orb(left: 60, top: -80, size: 420, color: const Color(0x807C3AED)),
          _orb(right: 20, bottom: 100, size: 320, color: const Color(0x5010B981)),
          _orb(left: -30, bottom: 220, size: 280, color: const Color(0x403B82F6)),
        ];
      case RGlowOrbsVariant.discovery:
        return [
          _orb(right: -50, top: -80, size: 460, color: const Color(0x737C3AED)),
          _orb(left: -50, top: 300, size: 360, color: const Color(0x5A4F46E5)),
          _orb(left: 120, bottom: 60, size: 260, color: const Color(0x4010B981)),
        ];
      default:
        return [
          _orb(left: -70, top: -90, size: 500, color: const Color(0x807C3AED)),
          _orb(right: -30, top: 180, size: 400, color: const Color(0x663B82F6)),
          _orb(left: 80, bottom: 0, size: 300, color: const Color(0x40F59E0B)),
        ];
    }
  }

  Widget _orb({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
