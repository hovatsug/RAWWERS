import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/core/money/eur.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/components/r_section_label.dart';
import 'package:rawwers/design/components/r_viewfinder_frame.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';

/// The top of the You tab: the brand, the date, and the money - what can be
/// withdrawn, framed, with what is still on its way under it, and a way to
/// ask for it when that is possible.
///
/// Every figure is the Wallet's own (the same controller), never a second
/// reading of the balance. "Request payout" appears only when the Wallet
/// would let a request through - an active payout account and nothing
/// blocking it; otherwise the Wallet explains why, as it always has. It opens
/// the Wallet, where the amount is chosen.
///
/// A screen reader hears the amount first, then the payout action, then the
/// rest of the band.
class YouBand extends ConsumerWidget {
  const YouBand({required this.walletPath, required this.settingsPath, super.key});

  final String walletPath;
  final String settingsPath;

  static const amountKey = ValueKey('you-band-amount');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletControllerProvider);

    return RHeaderBand(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Semantics(
            explicitChildNodes: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  container: true,
                  sortKey: const OrdinalSortKey(2),
                  child: Row(
                    children: [
                      // Plain text for now; the logo replaces it.
                      Text(
                        'RAWWERS',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontVariations: const [RType.weightSemibold],
                          letterSpacing: RType.label * RType.trackingSection,
                        ),
                      ),
                      const SizedBox(width: RSpace.s8),
                      Text(
                        'PRO',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: RType.label * RType.trackingSection,
                        ),
                      ),
                      const SizedBox(width: RSpace.s8),
                      Expanded(
                        child: Text(
                          RDates.of(context).dayDate(DateTime.now()),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: 'Settings',
                        onPressed: () => context.push(settingsPath),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RSpace.s16),
                // Said with the amount ("Available to withdraw, €41.95"), so
                // a screen reader does not hear the label twice or out of order.
                const ExcludeSemantics(child: RSectionLabel('Available to withdraw')),
                const SizedBox(height: RSpace.s8),
                switch (wallet) {
                  AsyncData(:final value) => _Money(data: value, walletPath: walletPath),
                  AsyncError() => Semantics(
                      container: true,
                  sortKey: const OrdinalSortKey(0),
                      child: Row(
                        children: [
                          Expanded(child: Text('Could not load your balance.', style: theme.textTheme.bodyMedium)),
                          TextButton(
                            onPressed: () => ref.invalidate(walletControllerProvider),
                            child: Text('Retry', style: TextStyle(color: theme.colorScheme.onSurface, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                  // The height the amount will take, so nothing jumps.
                  _ => const SizedBox(height: RType.hero + RSpace.s24 + RSpace.s32),
                },
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({required this.data, required this.walletPath});

  final WalletData data;
  final String walletPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = data.balance;
    final canRequest = data.account.status == PayoutAccountStatus.active && data.payoutBlockedReason == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
                  sortKey: const OrdinalSortKey(0),
          label: 'Available to withdraw, ${eur(balance.withdrawableEur)}',
          excludeSemantics: true,
          child: RViewfinderFrame(
            child: FittedBox(
              // Only the hero number may scale down: a long amount at a large
              // text size shrinks rather than clipping or wrapping.
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                eur(balance.withdrawableEur),
                key: YouBand.amountKey,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: RType.fontFamily,
                  fontSize: RType.hero,
                  fontVariations: const [RType.weightSemibold],
                  fontFeatures: RType.tabularFigures,
                  letterSpacing: RType.hero * RType.trackingHero,
                  height: RType.lineHeightDisplay,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: RSpace.s8),
        Semantics(
          container: true,
                  sortKey: const OrdinalSortKey(3),
          child: Text(
            '${eur(balance.pendingEur)} pending · ${eur(balance.heldEur)} on hold',
            style: theme.textTheme.bodySmall?.copyWith(fontFeatures: RType.tabularFigures),
          ),
        ),
        if (canRequest) ...[
          const SizedBox(height: RSpace.s16),
          Semantics(
            container: true,
                  sortKey: const OrdinalSortKey(1),
            child: ElevatedButton(
              onPressed: () => context.go(walletPath),
              child: const Text('Request payout'),
            ),
          ),
        ],
      ],
    );
  }
}
