import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:rawwers/design/components/r_section_label.dart';
import 'package:rawwers/design/components/r_viewfinder_frame.dart';
import 'package:rawwers/design/tokens.dart';

/// A screen's headline number on the dark band: its label in the section
/// style, and the number at hero size inside the viewfinder frame.
///
/// The frame spans the band at one height - the hero line at the reader's
/// text size - and the number sits left in it, scaling down when it is long,
/// so the frame never changes with what is inside. A screen reader hears the
/// label and the number as one ("Available to withdraw, €41.95").
class RBandHero extends StatelessWidget {
  const RBandHero({required this.label, required this.value, this.valueKey, this.sortKey, super.key});

  final String label;
  final String value;

  /// For a test to find the number itself.
  final Key? valueKey;

  /// Where the number falls in a screen reader's reading order, when a screen
  /// wants it read first.
  final SemanticsSortKey? sortKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Said with the number, so it is not heard twice.
        ExcludeSemantics(child: RSectionLabel(label)),
        const SizedBox(height: RSpace.s8),
        Semantics(
          container: true,
          sortKey: sortKey,
          label: '$label, $value',
          excludeSemantics: true,
          child: RViewfinderFrame(
            fullWidth: true,
            child: SizedBox(
              height: MediaQuery.textScalerOf(context).scale(RType.hero) * RType.lineHeightDisplay,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  key: valueKey,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: RType.fontFamily,
                    fontSize: RType.hero,
                    fontVariations: const [RType.weightSemibold],
                    fontFeatures: RType.tabularFigures,
                    letterSpacing: RType.hero * RType.trackingHero,
                    height: RType.lineHeightDisplay,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
