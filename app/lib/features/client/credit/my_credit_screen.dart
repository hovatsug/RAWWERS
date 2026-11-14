import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/credit/credit_controller.dart';
import 'package:rawwers/features/client/credit/credit_labels.dart';

/// Account > My credit: the balance, how to use it, how to earn it, and
/// every entry newest first. Shown in euros.
class MyCreditScreen extends ConsumerWidget {
  const MyCreditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final credit = ref.watch(myCreditProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My credit')),
      body: SafeArea(
        child: switch (credit) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.refresh(myCreditProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(RSpace.s16),
                children: [
                  Text('${creditAmount(value.balance, currency: value.currency)} credit', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: RSpace.s8),
                  Text(
                    'Use it on your next booking, up to ${value.maxDiscountPercent}% of the payment.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: RSpace.s16),
                  RCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ways to earn', style: theme.textTheme.titleSmall),
                        const SizedBox(height: RSpace.s4),
                        Text(
                          'Let RAWWERS feature photos from a booking you have rated. You are asked after rating it.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RSpace.s24),
                  Text('History', style: theme.textTheme.titleSmall),
                  const SizedBox(height: RSpace.s8),
                  if (value.items.isEmpty)
                    const REmptyState(
                      title: 'No credit yet',
                      body: 'Credit you earn and use shows here.',
                      icon: Icons.savings_outlined,
                    )
                  else
                    for (final item in value.items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(creditLabel(item)),
                        subtitle: Text(RDates.of(context).date(item.createdAt)),
                        trailing: Text(signedCreditAmount(item.amount, currency: item.currency), style: theme.textTheme.titleSmall),
                      ),
                ],
              ),
            ),
          AsyncError() => RErrorState(message: 'Your credit could not be loaded.', onRetry: () => ref.invalidate(myCreditProvider)),
          _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(height: 96)),
        },
      ),
    );
  }
}
