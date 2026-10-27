import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/tokens.dart';

/// A row of filter chips over a list (Gigs, Requests): always from the left
/// edge at the screen's 16px gutter, whether three chips fit or six do not,
/// and scrolling sideways when they do not - with the same 16px after the
/// last chip, so scrolled to its end it never touches the screen edge.
class RFilterBar<T> extends StatelessWidget {
  const RFilterBar({required this.values, required this.selected, required this.label, required this.onSelected, super.key});

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    // Full width, so a row narrower than the screen still starts at the
    // gutter instead of being centred by whatever column holds it.
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: RSpace.s16, vertical: RSpace.s8),
        child: Row(
          children: [
            for (final (i, value) in values.indexed) ...[
              if (i > 0) const SizedBox(width: RSpace.s8),
              RFilterChip(label: label(value), selected: value == selected, onPressed: () => onSelected(value)),
            ],
          ],
        ),
      ),
    );
  }
}
