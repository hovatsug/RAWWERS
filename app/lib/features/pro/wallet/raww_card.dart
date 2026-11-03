import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/pro_raww_view.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/wallet/raww_controller.dart';

/// "75 RAWW (€7.50)" once The Shelf is open (the server sends the RAWW
/// then), the euros alone before.
String rawwAmount(int? raww, String euros) => raww == null ? euros : '$raww RAWW ($euros)';

/// The Wallet's RAWW card: what can be spent on The Shelf now, what is
/// still waiting for its booking's earning to settle, and when the spendable
/// balance expires. Shown only while The Shelf is open.
class RawwCard extends ConsumerWidget {
  const RawwCard({this.shelfPath, super.key});

  /// Where "Browse The Shelf" goes.
  final String? shelfPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(rawwProvider)) {
      AsyncData(:final value) when value.shelfOpen => Padding(
          padding: const EdgeInsets.only(bottom: RSpace.s16),
          child: _Card(view: value, shelfPath: shelfPath),
        ),
      // Closed, still loading, or unreachable: the rest of the Wallet is
      // about money, and an empty RAWW card would only say nothing.
      _ => const SizedBox.shrink(),
    };
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.view, required this.shelfPath});

  final ProRawwView view;
  final String? shelfPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final dates = RDates.of(context);
    final euros = RMoney.of(context).format(
      (Decimal.fromInt(view.spendable < 0 ? 0 : view.spendable) * Decimal.parse(view.rawwEurValue)).toStringAsFixed(2),
    );

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RAWW for The Shelf', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          Text('${view.spendable} RAWW', style: theme.textTheme.headlineSmall),
          Text(
            view.spendable < 0
                ? 'Below zero after a refund. You can spend again once new RAWW bring it above the price.'
                : 'Worth $euros on The Shelf. Not cash, not withdrawable.',
            style: muted,
          ),
          if (view.pending > 0) ...[
            const SizedBox(height: RSpace.s16),
            Text('${view.pending} RAWW on the way', style: theme.textTheme.titleSmall),
            for (final booking in view.pendingBookings)
              Padding(
                padding: const EdgeInsets.only(top: RSpace.s4),
                child: Text(
                  booking.held || booking.expectedAt == null
                      ? '${booking.amount} RAWW, on hold with its booking'
                      : '${booking.amount} RAWW from ${dates.date(booking.expectedAt!)}',
                  style: muted,
                ),
              ),
          ],
          if (view.expiresAt case final expires?) ...[
            const SizedBox(height: RSpace.s16),
            _Expiry(date: dates.date(expires), warning: view.expiryWarning, months: view.inactivityMonths),
          ],
          if (shelfPath != null) ...[
            const SizedBox(height: RSpace.s16),
            RButton(label: 'Browse The Shelf', variant: RButtonVariant.secondary, onPressed: () => context.push(shelfPath!)),
          ],
        ],
      ),
    );
  }
}

class _Expiry extends StatelessWidget {
  const _Expiry({required this.date, required this.warning, required this.months});

  final String date;
  final bool warning;
  final int months;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = warning
        ? 'Your RAWW expire on $date. Earn or spend before then to keep them.'
        : 'Expire on $date if nothing is earned or spent before then ($months months without either).';
    if (!warning) {
      return Text(text, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RSpace.s12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(RRadius.surface),
      ),
      child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer)),
    );
  }
}
