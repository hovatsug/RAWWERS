import 'package:flutter/material.dart';

import '../tokens.dart';

class RBadge extends StatelessWidget {
  const RBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX2, vertical: RTokens.spacingX1),
      decoration: BoxDecoration(
        color: RTokens.brandSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: RTokens.brandPrimaryDark, fontWeight: FontWeight.w600),
      ),
    );
  }
}
