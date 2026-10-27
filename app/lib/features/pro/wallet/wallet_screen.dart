import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/design/components/r_amount_row.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/components/r_band_hero.dart';
import 'package:rawwers/api/models/earnings_ledger_item_view.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_request_view.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/router/app_router_pro.dart';
import 'package:rawwers/api/models/earnings_source_type.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/wallet/earnings_summary_card.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletControllerProvider);
    final notifier = ref.read(walletControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: SafeArea(
        child: switch (wallet) {
          AsyncLoading() => const PagedListSkeleton(itemCount: 3),
          AsyncError(:final error) => PagedListError(
            error: error,
            onRetry: notifier.refresh,
          ),
          AsyncData(:final value) => RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                // The headline number, on the band under the title.
                RHeaderBand(
                  padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s8, RSpace.s16, RSpace.s24),
                  child: RBandHero(label: 'Available to withdraw', value: RMoney.of(context).format(value.balance.withdrawableEur)),
                ),
                Padding(
                  padding: const EdgeInsets.all(RSpace.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                _BalanceCard(data: value),
                const SizedBox(height: RSpace.s16),
                // What the balance does not say: how it got there. The
                // balance is a position; this is the history behind it.
                const EarningsSummaryCard(),
                const SizedBox(height: RSpace.s16),
                _PayoutCard(data: value),
                const SizedBox(height: RSpace.s24),
                _PayoutHistory(payouts: value.payouts),
                const SizedBox(height: RSpace.s24),
                _Ledger(entries: value.ledger),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.data});

  final WalletData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money = RMoney.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The withdrawable figure is the band's headline above; this card
          // is where the rest of the money is.
          Text('Where your money is', style: theme.textTheme.titleMedium),
          if (data.balance.adjustmentOwedEur != '0.00') ...[
            const SizedBox(height: RSpace.s8),
            // Money paid out that a refund later took back. The server holds
            // the real (negative) balance; this screen shows 0 to withdraw
            // and says plainly what is owed and where it comes from.
            Text(
              'Adjustment owed: ${money.format(data.balance.adjustmentOwedEur)}. A booking was refunded after '
              'its earnings were paid out; this comes off your next earnings.',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: RSpace.s16),
          // The other buckets exist because money moves through stages -
          // showing only the withdrawable figure would make a photographer
          // think earnings vanished between a shoot and a payout.
          RAmountRow(label: 'Pending', amount: money.format(data.balance.pendingEur)),
          RAmountRow(label: 'On hold', amount: money.format(data.balance.heldEur)),
          // Asked for, not yet decided: out of what can be withdrawn the
          // moment it is asked for, back again if the request is rejected.
          RAmountRow(label: 'Requested', amount: money.format(data.balance.requestedEur)),
          RAmountRow(label: 'Reserved for payouts', amount: money.format(data.balance.reservedEur)),
          RAmountRow(label: 'Paid out', amount: money.format(data.balance.paidOutEur)),
        ],
      ),
    );
  }
}

class _PayoutCard extends ConsumerStatefulWidget {
  const _PayoutCard({required this.data});

  final WalletData data;

  @override
  ConsumerState<_PayoutCard> createState() => _PayoutCardState();
}

class _PayoutCardState extends ConsumerState<_PayoutCard> {
  final _amount = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final parsed = Decimal.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= Decimal.zero) {
      setState(() => _error = 'Enter an amount.');
      return;
    }
    if (parsed < PayoutRules.minimum) {
      setState(
        () => _error =
            'The minimum payout is ${RMoney.of(context).format(PayoutRules.minimum.toStringAsFixed(2))}.',
      );
      return;
    }
    if (parsed > widget.data.withdrawable) {
      setState(
        () => _error =
            'You can withdraw up to ${RMoney.of(context).format(widget.data.withdrawable.toStringAsFixed(2))}.',
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final message = await ref
        .read(walletControllerProvider.notifier)
        .requestPayout(parsed);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
    if (message == null) _amount.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.data;
    final accountReady = data.account.status == PayoutAccountStatus.active;
    final blocked = data.payoutBlockedReason;

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request a payout', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          _PayoutAccountStatus(status: data.account.status),
          if (!accountReady) ...[
            const SizedBox(height: RSpace.s8),
            Text(
              'Payouts need a verified account before they can be sent. '
              'Setting one up happens outside the app - we\'ll take you through it.',
              style: theme.textTheme.bodySmall,
            ),
          ] else if (blocked != null) ...[
            // Stated before the field, not after a rejected submit: the
            // server enforces these, and finding the floor by hitting it is a
            // worse way to learn it.
            const SizedBox(height: RSpace.s8),
            Text(blocked, style: theme.textTheme.bodySmall),
          ] else ...[
            const SizedBox(height: RSpace.s12),
            RInput(
              label: 'Amount (${RMoney.symbolFor(null)})',
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              tabularFigures: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: RSpace.s8),
              Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: RSpace.s12),
            RButton(
              label: 'Request payout',
              loading: _busy,
              onPressed: _busy ? null : _submit,
            ),
            const SizedBox(height: RSpace.s8),
            Text(
              'Minimum ${RMoney.of(context).format(PayoutRules.minimum.toStringAsFixed(2))}. '
              'Up to ${PayoutRules.requestsPer7Days} requests every 7 days.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _PayoutAccountStatus extends StatelessWidget {
  const _PayoutAccountStatus({required this.status});

  final PayoutAccountStatus status;

  @override
  Widget build(BuildContext context) {
    // Status only - bank details are the most sensitive input in the app and
    // Connect onboarding is a hosted flow rather than a form, so entry is a
    // task of its own rather than a field bolted onto this card.
    final (label, detail) = switch (status) {
      PayoutAccountStatus.active => (
        'Verified',
        'Payouts go to your verified account.',
      ),
      PayoutAccountStatus.pendingVerification => (
        'Being verified',
        'We\'re still checking your details.',
      ),
      PayoutAccountStatus.disabled => (
        'Disabled',
        'Your payout account needs attention before you can withdraw.',
      ),
      PayoutAccountStatus.notSet => (
        'Not set up',
        'You haven\'t added a payout account yet.',
      ),
    };

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        Text(detail, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _PayoutHistory extends StatelessWidget {
  const _PayoutHistory({required this.payouts});

  final List<PayoutRequestView> payouts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payouts', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s8),
        if (payouts.isEmpty)
          Text('No payouts yet.', style: theme.textTheme.bodySmall)
        else
          for (final payout in payouts) ...[
            RCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      payout.status.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    RMoney.of(context).format(payout.amountEur),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: RType.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RSpace.s8),
          ],
      ],
    );
  }
}

class _Ledger extends StatelessWidget {
  const _Ledger({required this.entries});

  final List<EarningsLedgerItemView> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Earnings', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s8),
        if (entries.isEmpty)
          Text('Nothing earned yet.', style: theme.textTheme.bodySmall)
        else ...[
          for (final entry in entries) ...[
            // Only gig earnings have an invoice behind them. An extras or
            // Studioverse row has no gig to itemise, so it stays flat rather
            // than offering a tap that goes nowhere.
            _MaybeTappable(
              onTap: entry.sourceType == EarningsSourceType.gigBase
                  ? () => context.push(ProRoute.invoice, extra: entry.sourceId)
                  : null,
              child: RCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sourceLabel(entry),
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            entry.status.name,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      RMoney.of(context).format(entry.netEur),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFeatures: RType.tabularFigures,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: RSpace.s8),
          ],
          // This endpoint takes a limit but no cursor, so there is no honest
          // way to page it. Saying so beats an infinite scroll that silently
          // stops, or a total that quietly excludes older entries.
          Text(
            'Showing your most recent earnings.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

String _sourceLabel(EarningsLedgerItemView entry) =>
    switch (entry.sourceType.name) {
      'gigBase' => 'Gig',
      'extraImages' => 'Extra images',
      'studioverseSale' => 'Studioverse sale',
      _ => 'Earning',
    };

/// Wraps a row in a tap target only when there is somewhere to go.
///
/// An InkWell with a null onTap still draws a splash on press, which reads as
/// a control that failed rather than one that was never there.
class _MaybeTappable extends StatelessWidget {
  const _MaybeTappable({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return InkWell(onTap: onTap, child: child);
  }
}
