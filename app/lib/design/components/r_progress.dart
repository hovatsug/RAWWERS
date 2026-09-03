import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A plain linear progress indicator - accent fill (one of the explicitly
/// accent-allowed uses: decay-curve visibility, $RAWW redemption progress,
/// tier-advancement progress).
class RProgressBar extends StatelessWidget {
  const RProgressBar({required this.value, super.key});

  /// 0.0-1.0
  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RRadius.control),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        valueColor: const AlwaysStoppedAnimation(RAccent.meter500),
      ),
    );
  }
}
