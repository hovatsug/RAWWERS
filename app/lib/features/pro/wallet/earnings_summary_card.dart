import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      _ => const RCard(child: RSkeleton(height: 120)),
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

          _Row(label: 'Booked', amount: '€${summary.gross}', emphasised: true),
          const SizedBox(height: RSpace.s8),
          _Row(label: 'Platform fees', amount: '-€${summary.platformFees}'),
          const SizedBox(height: RSpace.s8),
          _Row(label: 'Your RAWW credit', amount: '€${summary.proRaww}'),
          if (summary.clientRaww != '0.00') ...[
            const SizedBox(height: RSpace.s8),
            _Row(label: 'Given to clients', amount: '-€${summary.clientRaww}'),
          ],
          const Divider(height: RSpace.s24),
          _Row(label: 'Cash earned', amount: '€${summary.proCash}', emphasised: true),

          if (summary.averageGross != null) ...[
            const SizedBox(height: RSpace.s12),
            Text('Averaging €${summary.averageGross} a booking', style: muted),
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.amount, this.emphasised = false});

  final String label;
  final String amount;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasised ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(amount, style: style?.copyWith(fontFeatures: RType.tabularFigures)),
      ],
    );
  }
}
