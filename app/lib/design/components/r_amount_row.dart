import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// One line of a money card: a label on the left, an amount on the right.
///
/// The same size on both sides (body, 15) so a card's rows read as one
/// column of figures; the amount in tabular figures so the digits line up
/// from row to row; and only a [total] in the heavier weight, so the eye
/// lands on the line the others add up to. A [detail] (a rate, a reason)
/// sits under the label, small and muted.
class RAmountRow extends StatelessWidget {
  const RAmountRow({required this.label, required this.amount, this.detail, this.total = false, super.key});

  final String label;

  final String? detail;

  /// Already formatted (RMoney).
  final String amount;

  final bool total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weight = total ? const [RType.weightSemibold] : const [RType.weightRegular];
    final labelStyle = (total ? theme.textTheme.bodyLarge : theme.textTheme.bodyMedium)?.copyWith(fontVariations: weight);
    final amountStyle = theme.textTheme.bodyLarge?.copyWith(fontVariations: weight, fontFeatures: RType.tabularFigures);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: detail == null
                ? Text(label, style: labelStyle)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: labelStyle),
                      Text(detail!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
          ),
          const SizedBox(width: RSpace.s12),
          Text(amount, style: amountStyle),
        ],
      ),
    );
  }
}
