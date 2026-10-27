import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/api/models/connect_status_response.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/payouts/payouts_controller.dart';

/// Getting paid.
///
/// Leads with the money, because that is what the photographer came for,
/// and then says plainly what stands between them and it.
class PayoutsScreen extends ConsumerWidget {
  const PayoutsScreen({this.openUrl, super.key});

  /// How a hosted Stripe URL gets opened.
  ///
  /// Injected rather than called directly: opening an external browser
  /// needs url_launcher, which is not yet a dependency of this project.
  /// Until it is, the fallback copies the link to the clipboard - poor,
  /// but honest, and it keeps the flow testable without pretending the
  /// browser handoff works.
  final Future<bool> Function(String url)? openUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectStatusControllerProvider);
    final balance = ref.watch(earningsBalanceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payouts')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(connectStatusControllerProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(RSpace.s16),
            children: [
              switch (balance) {
                AsyncData(:final value) => _Balance(balance: value),
                AsyncError() => const _Unavailable('Could not load your earnings.'),
                _ => const RCard(child: RSkeleton(width: RSize.lineShort)),
              },
              const SizedBox(height: RSpace.s24),
              switch (status) {
                AsyncData(:final value) => _ConnectSection(status: value, openUrl: openUrl),
                AsyncError() => RErrorState(
                    message: 'Could not check your payout setup.',
                    onRetry: () => ref.invalidate(connectStatusControllerProvider),
                  ),
                _ => const RCard(child: RSkeleton(width: RSize.lineMedium)),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance({required this.balance});

  final EarningsBalanceView balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money = RMoney.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(money.format(balance.withdrawableEur), style: theme.textTheme.headlineSmall),
          Text('ready to withdraw', style: theme.textTheme.bodySmall),
          const Divider(height: RSpace.s24),
          _Line(label: 'Earned, still settling', value: money.format(balance.pendingEur)),
          const SizedBox(height: RSpace.s4),
          // "Pending" should read as when, not whether.
          Text(
            'Money from a finished shoot settles before it can be withdrawn.',
            style: theme.textTheme.bodySmall,
          ),
          if (balance.heldEur != '0.00') ...[
            const SizedBox(height: RSpace.s12),
            _Line(label: 'On hold', value: money.format(balance.heldEur)),
          ],
        ],
      ),
    );
  }
}

class _ConnectSection extends ConsumerStatefulWidget {
  const _ConnectSection({required this.status, required this.openUrl});

  final ConnectStatusResponse status;
  final Future<bool> Function(String url)? openUrl;

  @override
  ConsumerState<_ConnectSection> createState() => _ConnectSectionState();
}

class _ConnectSectionState extends ConsumerState<_ConnectSection> {
  bool _starting = false;
  String? _error;
  String? _copiedUrl;

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
      _copiedUrl = null;
    });

    // Requested fresh every tap. Stripe links expire in minutes and are
    // single use, so reusing one is how a photographer ends up staring at
    // an expired page with no idea why.
    final outcome = await ref.read(connectStatusControllerProvider.notifier).onboardingLink();
    if (!mounted) return;

    if (outcome.url == null) {
      setState(() {
        _starting = false;
        _error = outcome.error;
      });
      return;
    }

    final opened = await widget.openUrl?.call(outcome.url!) ?? false;
    if (!mounted) return;

    if (!opened) {
      await Clipboard.setData(ClipboardData(text: outcome.url!));
      if (!mounted) return;
      setState(() {
        _starting = false;
        _copiedUrl = outcome.url;
      });
      return;
    }
    setState(() => _starting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.status;
    final due = [...?status.currentlyDue, ...?status.pastDue];

    final (title, body, action) = switch (status.accountStatus) {
      'active' => ('Set up', 'Withdrawals will reach your bank.', null),
      'pending_verification' when status.detailsSubmitted =>
        ('Stripe is checking your details', 'Nothing more to do for now.', 'Check again'),
      'pending_verification' => ('Not finished yet', 'Stripe still needs a few things from you.', 'Continue setup'),
      'disabled' => (
          'Stripe cannot pay out yet',
          status.disabledReason ?? 'Stripe has paused payouts on this account.',
          'Fix this'
        ),
      _ => (
          'You cannot be paid yet',
          'Set up payouts so money from finished shoots can reach your bank. '
              'Stripe handles this and asks for your ID.',
          'Set up payouts'
        ),
    };

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              RStatusChip(
                label: status.accountStatus == 'active' ? 'Ready' : 'Not ready',
                kind: status.accountStatus == 'active'
                    ? RStatusChipKind.positive
                    : RStatusChipKind.inProgress,
              ),
            ],
          ),
          const SizedBox(height: RSpace.s8),
          Text(body, style: theme.textTheme.bodySmall),
          if (due.isNotEmpty) ...[
            const SizedBox(height: RSpace.s12),
            Text('Still needed:', style: theme.textTheme.bodyMedium),
            const SizedBox(height: RSpace.s4),
            // Raw requirement keys read as a database schema; the whole
            // point of showing them is that they are actionable.
            for (final key in due)
              Padding(
                padding: const EdgeInsets.only(top: RSpace.s2),
                child: Text('· ${requirementLabel(key)}', style: theme.textTheme.bodySmall),
              ),
          ],
          if (_error != null) ...[
            const SizedBox(height: RSpace.s12),
            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ],
          if (_copiedUrl != null) ...[
            const SizedBox(height: RSpace.s12),
            Text(
              'Link copied. Open it in your browser to finish — it expires in a few minutes, '
              'so tap again for a new one if it stops working.',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: RSpace.s16),
            RButton(label: action, onPressed: _starting ? null : _start, loading: _starting),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable(this.message);

  final String message;

  @override
  Widget build(BuildContext context) =>
      RCard(child: Text(message, style: Theme.of(context).textTheme.bodyMedium));
}
