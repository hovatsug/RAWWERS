import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/api/models/gig_invoice_view.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/wallet/invoice_controller.dart';

/// What one gig actually paid, line by line.
///
/// Every figure is the server's. Nothing on this screen is added up locally,
/// including the total - the invoice reconciles server-side and repeating the
/// arithmetic here would only create a second answer to compare against.
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
                children: [RSkeleton(width: 200), SizedBox(height: RSpace.s16), RSkeleton(height: 180)],
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

  String get _symbol => switch (invoice.currency.toUpperCase()) {
        'EUR' => '€',
        'GBP' => '£',
        'USD' => r'$',
        _ => '${invoice.currency} ',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = invoice.issuedAt;

    return ListView(
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        Text(
          RDates.of(context).date(date),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: RSpace.s4),
        Text('$_symbol${invoice.clientTotal}', style: theme.textTheme.headlineMedium),
        Text(
          'What your client paid',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: RSpace.s24),

        RCard(
          child: Column(
            children: [
              _Line(
                label: 'Platform fee',
                detail: '${invoice.retainedPercent}% of the booking',
                amount: '-$_symbol${invoice.platformRetained}',
              ),
              const SizedBox(height: RSpace.s12),
              _Line(
                label: 'Your RAWW credit',
                detail: '${invoice.proRawwPercent}% back to you',
                amount: '$_symbol${invoice.proRaww}',
              ),
              if (invoice.clientCreditPercent > 0) ...[
                const SizedBox(height: RSpace.s12),
                _Line(
                  label: 'Credit to your client',
                  detail: '${invoice.clientCreditPercent}%, from your share',
                  amount: '-$_symbol${invoice.clientRaww}',
                ),
              ],
              const Divider(height: RSpace.s24),
              _Line(
                label: 'Your cash',
                amount: '$_symbol${invoice.proCash}',
                emphasised: true,
              ),
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
                _Line(label: 'Before VAT', amount: '$_symbol${invoice.vatNetAmount}'),
                const SizedBox(height: RSpace.s12),
                _Line(
                  label: 'VAT',
                  detail: '${invoice.vatRatePercent}%'
                      '${invoice.vatNumber == null ? '' : ' · ${invoice.vatNumber}'}',
                  amount: '$_symbol${invoice.vatAmount}',
                ),
                const Divider(height: RSpace.s24),
                _Line(
                  label: 'Total paid',
                  amount: '$_symbol${invoice.clientTotal}',
                  emphasised: true,
                ),
              ] else
                _Line(
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
          child: _Line(
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
          child: _Line(
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

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.amount,
    this.detail,
    this.emphasised = false,
  });

  final String label;
  final String amount;
  final String? detail;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasised ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: style),
              if (detail != null)
                Text(
                  detail!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        Text(amount, style: style?.copyWith(fontFeatures: RType.tabularFigures)),
      ],
    );
  }
}
