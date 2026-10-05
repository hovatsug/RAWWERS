import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A short label overlaid on top of something else - a photo tile whose
/// image is real but whose state needs a word ("Processing", "Cover",
/// "Untagged"). Not [RStatusChip]: that reports a booking/gig's state as a
/// standalone row element, this sits on top of content that is already
/// there, small enough not to compete with it.
///
/// One implementation so "processing" reads the same way everywhere it
/// appears - first written for the portfolio grid, reused by the delivery
/// upload grid rather than a second copy of the same eleven lines.
class ROverlayBadge extends StatelessWidget {
  const ROverlayBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RSpace.s8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.inverseSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(RRadius.control),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}
