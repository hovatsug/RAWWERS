import 'package:flutter/material.dart';
import '../tokens.dart';

enum RBadgeVariant { defaultBadge, violet, emerald, amber }

class RBadge extends StatelessWidget {
  const RBadge({
    super.key,
    required this.label,
    this.variant = RBadgeVariant.defaultBadge,
  });

  final String label;
  final RBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (variant) {
      RBadgeVariant.violet  => (const Color(0x337C3AED), const Color(0x4D7C3AED), RTokens.violetLight),
      RBadgeVariant.emerald => (const Color(0x3310B981), const Color(0x4D10B981), RTokens.emerald),
      RBadgeVariant.amber   => (const Color(0x33F59E0B), const Color(0x4DF59E0B), RTokens.amber),
      _                     => (RTokens.glassCardBg, RTokens.glassCardBorder, RTokens.textMutedDark),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX2 + 2, vertical: RTokens.spacingX1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: RTokens.textXs,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
