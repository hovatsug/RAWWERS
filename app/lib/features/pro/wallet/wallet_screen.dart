import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/earnings_ledger_item_view.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_request_view.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';
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
          AsyncError(:final error) => PagedListError(error: error, onRetry: notifier.refresh),
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: notifier.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(RSpace.s16),
                children: [
                  _BalanceCard(data: value),
                  const SizedBox(height: RSpace.s16),
                  _PayoutCard(data: value),
                  const SizedBox(height: RSpace.s24),
                  _PayoutHistory(payouts: value.payouts),
                  const SizedBox(height: RSpace.s24),
                  _Ledger(entries: value.ledger),
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
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available to withdraw', style: theme.textTheme.bodyMedium),
          const SizedBox(height: RSpace.s4),
          Text(
            '€${data.balance.withdrawableEur}',
            style: theme.textTheme.displaySmall?.copyWith(fontFeatures: RType.tabularFigures),
          ),
          const SizedBox(height: RSpace.s16),
          // The other four buckets exist because money moves through stages -
          // showing only the withdrawable figure would make a photographer
          // think earnings vanished between a shoot and a payout.
          _BalanceRow(label: 'Pending', amount: data.balance.pendingEur),
          _BalanceRow(label: 'Available', amount: data.balance.availableEur),
          _BalanceRow(label: 'On hold', amount: data.balance.heldEur),
          _BalanceRow(label: 'Reserved', amount: data.balance.reservedEur),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RSpace.s4),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const Spacer(),
          Text(
            '€$amount',
            style: theme.textTheme.bodyMedium?.copyWith(fontFeatures: RType.tabularFigures),
          ),
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
      setState(() => _error = 'The minimum payout is €${PayoutRules.minimum.toStringAsFixed(2)}.');
      return;
    }
    if (parsed > widget.data.withdrawable) {
      setState(() => _error = 'You can withdraw up to €${widget.data.withdrawable.toStringAsFixed(2)}.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final message = await ref.read(walletControllerProvider.notifier).requestPayout(parsed);
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
              label: 'Amount (€)',
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              tabularFigures: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: RSpace.s8),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: RSpace.s12),
            RButton(label: 'Request payout', loading: _busy, onPressed: _busy ? null : _submit),
            const SizedBox(height: RSpace.s8),
            Text(
              'Minimum €${PayoutRules.minimum.toStringAsFixed(2)}. '
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
      PayoutAccountStatus.active => ('Verified', 'Payouts go to your verified account.'),
      PayoutAccountStatus.pendingVerification => ('Being verified', 'We\'re still checking your details.'),
      PayoutAccountStatus.disabled => ('Disabled', 'Your payout account needs attention before you can withdraw.'),
      PayoutAccountStatus.notSet => ('Not set up', 'You haven\'t added a payout account yet.'),
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
                  Expanded(child: Text(payout.status.name, style: theme.textTheme.bodyMedium)),
                  Text(
                    '€${payout.amountEur}',
                    style: theme.textTheme.titleMedium?.copyWith(fontFeatures: RType.tabularFigures),
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
            RCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_sourceLabel(entry), style: theme.textTheme.bodyMedium),
                        Text(entry.status.name, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    '€${entry.netEur}',
                    style: theme.textTheme.titleMedium?.copyWith(fontFeatures: RType.tabularFigures),
                  ),
                ],
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

String _sourceLabel(EarningsLedgerItemView entry) => switch (entry.sourceType.name) {
      'gigBase' => 'Gig',
      'extraImages' => 'Extra images',
      'studioverseSale' => 'Studioverse sale',
      _ => 'Earning',
    };
