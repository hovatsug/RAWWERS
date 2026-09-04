import 'package:flutter/material.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/gigs/gig_status_display.dart';

class GigCard extends StatelessWidget {
  const GigCard({required this.gig, this.onTap, super.key});

  final GigResponse gig;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    gig.scheduledStart != null ? _scheduleLine(gig.scheduledStart!) : 'Not scheduled yet',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: RSpace.s12),
                RStatusChip(label: gig.status.label, kind: gig.status.chipKind),
              ],
            ),
            if (gig.locationText != null) ...[
              const SizedBox(height: RSpace.s4),
              Text(gig.locationText!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: RSpace.s12),
            Row(
              children: [
                Text('You earn', style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(
                  // Money arrives as a decimal string and is rendered as one -
                  // never parsed to a double on the way to the screen.
                  '€${gig.amountProGross}',
                  style: theme.textTheme.titleMedium?.copyWith(fontFeatures: RType.tabularFigures),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _scheduleLine(DateTime utc) {
  final local = utc.toLocal();
  final date = '${local.day}/${local.month}/${local.year}';
  final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '$date · $time';
}
