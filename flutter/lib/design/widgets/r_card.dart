import 'package:flutter/material.dart';

import '../tokens.dart';

class RCard extends StatelessWidget {
  const RCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(RTokens.spacingX4),
      decoration: BoxDecoration(
        color: RTokens.neutralCard,
        borderRadius: BorderRadius.circular(RTokens.radiusLg),
        boxShadow: const [BoxShadow(color: Color(0x140F172A), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: child,
    );
  }
}
