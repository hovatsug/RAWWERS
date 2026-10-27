import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/api/models/gig_invoice_view.dart';
import 'package:rawwers/design/components/r_amount_row.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/wallet/invoice_controller.dart';

/// What one gig actually paid, line by line.
///
/// Every figure is the server's, and the total is never recomputed here - the
/// invoice reconciles server-side. The one sum on screen is the platform's
/// whole fee, retained plus RAWW credit, the same two server figures the
/// Wallet's "Platform fees" adds (summarise_invoices), so the rows a
/// photographer reads add up to Your cash.
class InvoiceScreen extends ConsumerWidget {
  const InvoiceScreen({required this.gigId, super.key});

  final String gigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider(gigId: gigId));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: SafeArea(
        child: switch (invoice) {
          AsyncData(:final GigInvoiceView value) => _Invoice(invoice: value),
          AsyncError() => RErrorState(
              message: 'Could not load this invoice.',
              onRetry: () => ref.invalidate(invoiceProvider(gigId: gigId)),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: RSize.lineMedium), SizedBox(height: RSpace.s16), RSkeleton(height: RSize.blockList)],
              ),
            ),
        },
      ),
    );
  }
}

class _Invoice extends StatelessWidget {
  const _Invoice({required this.invoice});

  final GigInvoiceView invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = invoice.issuedAt;
    final money = RMoney.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    String amount(String value) => money.format(value, currency: invoice.currency);
    String minus(String value) => money.minus(value, currency: invoice.currency);

    return ListView(
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        Text(
          RDates.of(context).date(date),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: RSpace.s4),
        Text(amount(invoice.clientTotal), style: theme.textTheme.headlineMedium),
        Text(
          'What your client paid',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: RSpace.s24),

        // A sum that adds up, as the Wallet's All time card does: the
        // booking, less the platform's fee and any credit given to the
        // client, is Your cash. The RAWW credit is part of that fee and not
        // cash, so it sits under the total, apart from the sum.
        RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RAmountRow(label: 'Booked', amount: amount(invoice.clientTotal)),
              RAmountRow(
                label: 'Platform fee',
                detail: '${invoice.retainedPercent + invoice.proRawwPercent}% of the booking',
                amount: minus((Decimal.parse(invoice.platformRetained) + Decimal.parse(invoice.proRaww)).toStringAsFixed(2)),
              ),
              if (invoice.clientCreditPercent > 0)
                RAmountRow(
                  label: 'Credit to your client',
                  detail: '${invoice.clientCreditPercent}%, from your share',
                  amount: minus(invoice.clientRaww),
                ),
              const Divider(height: RSpace.s16),
              RAmountRow(label: 'Your cash', amount: amount(invoice.proCash), total: true),
              if (invoice.proRawwPercent > 0) ...[
                const SizedBox(height: RSpace.s12),
                RAmountRow(
                  label: 'Your RAWW credit',
                  detail: '${invoice.proRawwPercent}% of the booking',
                  amount: amount(invoice.proRaww),
                ),
                const SizedBox(height: RSpace.s4),
                Text('Gear credit, part of the platform fee. Not withdrawable.', style: muted),
              ],
            ],
          ),
        ),
        const SizedBox(height: RSpace.s16),

        // VAT, or an explicit statement that none applies. Never an absent
        // line: a photographer needs to know which of the two an invoice is,
        // and silence looks like an oversight rather than a fact.
        RCard(
          child: Column(
            children: [
              if (invoice.vatAmount != null && invoice.vatNetAmount != null) ...[
                RAmountRow(label: 'Before VAT', amount: amount(invoice.vatNetAmount!)),
                RAmountRow(
                  label: 'VAT',
                  detail: '${invoice.vatRatePercent}%'
                      '${invoice.vatNumber == null ? '' : ' · ${invoice.vatNumber}'}',
                  amount: amount(invoice.vatAmount!),
                ),
                const Divider(height: RSpace.s16),
                RAmountRow(
                  label: 'Total paid',
                  amount: amount(invoice.clientTotal),
                  total: true,
                ),
              ] else
                RAmountRow(
                  label: 'VAT',
                  detail: switch (invoice.vatStatus) {
                    'registered' => 'No rate is configured for your country yet.',
                    'not_registered' => 'You are not VAT registered, so none was charged.',
                    // Never "not registered". Being unregistered is something
                    // a photographer tells us, not something inferred from
                    // their silence.
                    _ => 'You have not told us your VAT status yet.',
                  },
                  amount: 'None',
                ),
            ],
          ),
        ),
        const SizedBox(height: RSpace.s16),

        RCard(
          child: RAmountRow(
            label: "RAWWERS' VAT on its fee",
            // Deliberately not a number. It depends on where RAWWERS
            // incorporates, which is undecided, and a plausible figure here
            // would be worse than an honest blank.
            detail: 'Not yet determined',
            amount: '—',
          ),
        ),
        const SizedBox(height: RSpace.s16),

        RCard(
          child: RAmountRow(
            label: 'Photos delivered',
            // Never a zero. A completed gig with no recorded selection has an
            // unknown count, and printing 0 would tell a photographer they
            // delivered nothing.
            amount: invoice.photosDelivered?.toString() ?? 'Not recorded',
          ),
        ),

        if (invoice.ratesWereStamped == false) ...[
          const SizedBox(height: RSpace.s16),
          Text(
            'This booking predates itemised rates, so the split above is '
            'reconstructed from current rates rather than recorded at the time.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
