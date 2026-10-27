import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/design/components/r_amount_row.dart';
import 'package:rawwers/api/models/invoice_summary_view.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/wallet/summary_controller.dart';

/// Everything a photographer has earned, totalled.
///
/// Sits above the per-transaction list rather than replacing it: the ledger
/// answers "what happened", this answers "how has it gone". Every figure is
/// the server's own total of the same invoices the ledger rows open.
class EarningsSummaryCard extends ConsumerWidget {
  const EarningsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(earningsSummaryProvider);

    return switch (summary) {
      AsyncData(:final InvoiceSummaryView value) when value.bookings == 0 => const SizedBox.shrink(),
      AsyncData(:final InvoiceSummaryView value) => _Summary(summary: value),
      // An error here hides the summary rather than the whole Wallet. The
      // balance and the ledger are separate requests and still worth showing.
      AsyncError() => const SizedBox.shrink(),
      _ => const RCard(child: RSkeleton(height: RSize.blockPanel)),
    };
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.summary});

  final InvoiceSummaryView summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final money = RMoney.of(context);

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All time', style: theme.textTheme.titleMedium),
          Text(
            '${summary.bookings} completed ${summary.bookings == 1 ? 'booking' : 'bookings'}',
            style: muted,
          ),
          const SizedBox(height: RSpace.s16),

          // A sum that adds up: Booked, less the platform's whole fee and
          // anything given to clients, is the cash earned - to the cent, as
          // the server splits it (platform_fees already holds the RAWW
          // credit, which is part of the fee). The RAWW credit sits under
          // the total, apart from the sum, because it is not cash.
          RAmountRow(label: 'Booked', amount: money.format(summary.gross)),
          RAmountRow(label: 'Platform fees', amount: money.minus(summary.platformFees)),
          if (summary.clientRaww != '0.00')
            RAmountRow(label: 'Given to clients', amount: money.minus(summary.clientRaww)),
          const Divider(height: RSpace.s16),
          RAmountRow(label: 'Cash earned', amount: money.format(summary.proCash), total: true),
          const SizedBox(height: RSpace.s12),
          RAmountRow(label: 'Your RAWW credit', amount: money.format(summary.proRaww)),
          const SizedBox(height: RSpace.s4),
          Text('Gear credit, part of the platform fee. Not withdrawable.', style: muted),

          if (summary.averageGross != null) ...[
            const SizedBox(height: RSpace.s12),
            Text('Averaging ${money.format(summary.averageGross!)} a booking', style: muted),
          ],

          if (summary.reconstructed > 0) ...[
            const SizedBox(height: RSpace.s8),
            Text(
              // Honest about its own provenance, for the same reason the
              // invoice screen is: these totals are partly reconstructed.
              '${summary.reconstructed} of these predate itemised rates, so their '
              'split is reconstructed from current rates.',
              style: muted,
            ),
          ],
        ],
      ),
    );
  }
}
