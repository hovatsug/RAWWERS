import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/api/models/connect_status_response.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/payout_setup_state.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/payouts/payout_links.dart';
import 'package:rawwers/features/pro/payouts/payouts_controller.dart';

/// Getting paid.
///
/// Leads with the money, because that is what the photographer came for,
/// and then says plainly what stands between them and it.
class PayoutsScreen extends ConsumerWidget {
  const PayoutsScreen({this.openUrl, super.key});

  /// How a hosted Stripe URL gets opened. By default the device's in-app
  /// browser (PayoutLinkPlatform); a test may pass its own. When nothing
  /// can open it, the link is copied to the clipboard instead.
  final Future<bool> Function(String url)? openUrl;

  /// Everything on the screen, asked again: the earnings as well as the
  /// setup, so a failed earnings load does not outlive the retry.
  static Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(earningsBalanceControllerProvider);
    try {
      await ref.read(connectStatusControllerProvider.notifier).refresh();
    } on Object {
      // The setup section shows its own error state.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectStatusControllerProvider);
    final balance = ref.watch(earningsBalanceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payouts')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
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
              // A failed read shows the error, never the last answer: coming
              // back from Stripe with no connection must not leave yesterday's
              // "Continue setup" on screen as if it were current.
              switch (status) {
                AsyncData(:final value) => _ConnectSection(
                    status: value,
                    checking: status.isLoading,
                    openUrl: openUrl,
                    onCheckAgain: () => _refresh(ref),
                  ),
                AsyncError() => RErrorState(
                    message: 'Couldn\'t check your payout setup. Check your connection and try again.',
                    retryLabel: 'Try again',
                    onRetry: () => _refresh(ref),
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
  const _ConnectSection({
    required this.status,
    required this.checking,
    required this.openUrl,
    required this.onCheckAgain,
  });

  final ConnectStatusResponse status;

  /// The status is being asked again. Its last answer stays on screen, but
  /// nothing can be started from it until the new one arrives.
  final bool checking;
  final Future<bool> Function(String url)? openUrl;
  final Future<void> Function() onCheckAgain;

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

    final open = widget.openUrl ?? (url) => ref.read(payoutLinkPlatformProvider).open(Uri.parse(url));
    final opened = await open(outcome.url!);
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
    final state = status.setupState;
    final copy = setupCopy(state);
    // What is due only helps while there is something to do about it.
    final rows = switch (state) {
      PayoutSetupState.inProgress || PayoutSetupState.actionNeeded =>
        requirementRows([...?status.currentlyDue, ...?status.pastDue]),
      _ => const <String>[],
    };

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(copy.title, style: theme.textTheme.titleSmall)),
              RStatusChip(
                label: switch (state) {
                  PayoutSetupState.ready => 'Ready',
                  PayoutSetupState.disabled => 'Stopped',
                  _ => 'Not ready',
                },
                kind: switch (state) {
                  PayoutSetupState.ready => RStatusChipKind.positive,
                  PayoutSetupState.disabled => RStatusChipKind.stopped,
                  _ => RStatusChipKind.inProgress,
                },
              ),
            ],
          ),
          const SizedBox(height: RSpace.s8),
          Text(copy.body, style: theme.textTheme.bodySmall),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: RSpace.s12),
            Text('Still needed', style: theme.textTheme.bodyMedium),
            const SizedBox(height: RSpace.s4),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(top: RSpace.s2),
                child: Text('· $row', style: theme.textTheme.bodySmall),
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
          if (copy.action != null) ...[
            const SizedBox(height: RSpace.s16),
            RButton(
              label: copy.action!,
              loading: _starting || widget.checking,
              onPressed: _starting || widget.checking
                  ? null
                  // Under review there is nothing to fill in: the button asks
                  // Stripe again rather than opening its form.
                  : state == PayoutSetupState.underReview
                      ? widget.onCheckAgain
                      : _start,
            ),
          ],
        ],
      ),
    );
  }
}

/// What the screen says for each setup state the server reports: a title,
/// what it means, and the one thing to do next (none when there is
/// nothing the photographer can do here).
({String title, String body, String? action}) setupCopy(PayoutSetupState state) => switch (state) {
      PayoutSetupState.notStarted => (
          title: 'You can\'t be paid yet',
          body: 'Set up payouts so money from finished shoots can reach your bank. '
              'Stripe handles this and asks for your ID.',
          action: 'Set up payouts',
        ),
      PayoutSetupState.inProgress => (
          title: 'Setup isn\'t finished',
          body: 'Stripe still needs a few details. You can pick up where you left off.',
          action: 'Continue setup',
        ),
      PayoutSetupState.underReview => (
          title: 'Stripe is checking your details',
          body: 'This usually takes a few minutes, sometimes a day or two. Nothing to do for now.',
          action: 'Check again',
        ),
      PayoutSetupState.actionNeeded => (
          title: 'Stripe needs something else from you',
          body: 'Open Stripe to add what is missing.',
          action: 'Fix this',
        ),
      PayoutSetupState.ready => (
          title: 'Payouts are set up',
          body: 'Withdrawals go to the bank account you gave Stripe.',
          action: null,
        ),
      PayoutSetupState.disabled => (
          title: 'Stripe can\'t pay out to this account',
          body: 'Contact us and we\'ll look into it with Stripe.',
          action: null,
        ),
    };

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
