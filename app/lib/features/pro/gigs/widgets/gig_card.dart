import 'package:flutter/material.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/core/format/dates.dart';
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

    final note = gig.status.deliveryNote;

    return InkWell(
      // Null for a booking that cannot take delivery: the card is then not a
      // button at all, rather than one that leads to an error.
      onTap: gig.status.canOpenDelivery ? onTap : null,
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
                    gig.scheduledStart != null ? _scheduleLine(RDates.of(context), gig.scheduledStart!) : 'Not scheduled yet',
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
                  RMoney.of(context).format(gig.amountProGross, currency: gig.currency),
                  style: theme.textTheme.titleMedium?.copyWith(fontFeatures: RType.tabularFigures),
                ),
              ],
            ),
            if (note != null) ...[
              const SizedBox(height: RSpace.s8),
              Text(note, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

String _scheduleLine(RDates dates, DateTime at) => '${dates.date(at)} · ${dates.time(at)}';
