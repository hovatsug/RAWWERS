import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens.dart';

class RCard extends StatelessWidget {
  const RCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RTokens.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(RTokens.spacingX4),
          decoration: RTokens.glassDecoration(),
          child: child,
        ),
      ),
    );
  }
}
