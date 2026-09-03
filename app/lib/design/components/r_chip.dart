import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// The booking flow's 15 states collapse to three visual signals - the
/// state name (passed as [label]) carries the specific meaning, this only
/// carries "is this ongoing, done, or broken". Feature code maps its own
/// booking-state enum onto one of these three; the design system doesn't
/// know the domain's state names.
enum RStatusChipKind {
  /// DRAFT, REQUESTED, ACCEPTED, CONFIRMED, SHOOT_COMPLETED,
  /// GALLERY_UPLOADED, AWAITING_SELECTION, SELECTED, DIFFERENCE_CHARGED,
  /// AWAITING_REVIEW, REVIEWED - plain outline, no color meaning beyond
  /// "still going".
  inProgress,

  /// DELIVERED, CLOSED - outline in RDevelop.develop500.
  positive,

  /// CANCELLED, DISPUTED - filled, not outline (unlike the other two
  /// kinds): these are the two states that must be noticed immediately.
  stopped,
}

class RStatusChip extends StatelessWidget {
  const RStatusChip({required this.label, required this.kind, super.key});

  final String label;
  final RStatusChipKind kind;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final (Color borderColor, Color textColor, Color? fill) = switch (kind) {
      RStatusChipKind.inProgress => (onSurface.withValues(alpha: 0.4), onSurface, null),
      RStatusChipKind.positive => (RDevelop.develop500, RDevelop.develop500, null),
      RStatusChipKind.stopped => (RShade.shade600, RInk.i050, RShade.shade600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RSpace.s12, vertical: RSpace.s4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(RRadius.control),
        border: fill == null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: RType.fontFamily,
          fontSize: RType.caption,
          fontVariations: const [RType.weightMedium],
          color: textColor,
        ),
      ),
    );
  }
}
