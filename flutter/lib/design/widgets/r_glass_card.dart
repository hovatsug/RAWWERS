import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens.dart';

/// A frosted-glass surface widget using BackdropFilter.
/// Wrap screen content in a Stack with [RGlowOrbs] beneath for full effect.
class RGlassCard extends StatelessWidget {
  const RGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blurSigma = 20.0,
    this.radius = RTokens.radiusXl,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(RTokens.spacingX4),
          decoration: RTokens.glassDecoration(radius: radius),
          child: child,
        ),
      ),
    );
  }
}
