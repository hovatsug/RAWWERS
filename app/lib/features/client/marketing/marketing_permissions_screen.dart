import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/marketing_consent_view.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/marketing/marketing_consent_controllers.dart';

/// How long before its end a permission offers "Renew" (the server sends
/// the in-app reminder at the same point).
const renewWithin = Duration(days: 30);

/// Account > Marketing permissions: every photo the client has let RAWWERS
/// feature, with its end date; withdraw one, or all.
class MarketingPermissionsScreen extends ConsumerWidget {
  const MarketingPermissionsScreen({super.key, this.now});

  /// For tests; the clock otherwise.
  final DateTime Function()? now;

  Future<void> _act(BuildContext context, Future<String?> Function() action, String done) async {
    final messenger = ScaffoldMessenger.of(context);
    final problem = await action();
    messenger.showSnackBar(SnackBar(content: Text(problem ?? done)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consents = ref.watch(myMarketingConsentsControllerProvider);
    final controller = ref.read(myMarketingConsentsControllerProvider.notifier);
    final theme = Theme.of(context);
    final today = (now ?? DateTime.now)();

    return Scaffold(
      appBar: AppBar(title: const Text('Marketing permissions')),
      body: SafeArea(
        child: switch (consents) {
          AsyncData(:final value) when value.isEmpty => const REmptyState(
              title: 'Nothing shared',
              body: 'Photos you let RAWWERS feature appear here, with when each permission ends.',
              icon: Icons.campaign_outlined,
            ),
          AsyncData(:final value) => ListView(
              padding: const EdgeInsets.all(RSpace.s16),
              children: [
                Text(
                  'RAWWERS may show these on its own channels until the date shown. Withdraw any of them at any time; '
                  'RAWWERS then takes them down within 30 days.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: RSpace.s12),
                for (final consent in value) ...[
                  _PermissionRow(
                    consent: consent,
                    endingSoon: consent.status == 'active' && consent.endsAt.difference(today) <= renewWithin,
                    onWithdraw: () => _act(context, () => controller.withdraw([consent.id]), 'Withdrawn.'),
                    onRenew: () => _act(context, () => controller.renew([consent.id]), 'Renewed for 12 months.'),
                  ),
                  const SizedBox(height: RSpace.s8),
                ],
                if (value.any((c) => c.status == 'active')) ...[
                  const SizedBox(height: RSpace.s16),
                  RButton(
                    label: 'Withdraw all',
                    variant: RButtonVariant.secondary,
                    onPressed: () => _act(context, () => controller.withdraw(null), 'All withdrawn.'),
                  ),
                ],
              ],
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your marketing permissions.',
              onRetry: () => ref.invalidate(myMarketingConsentsControllerProvider),
            ),
          _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(height: 80)),
        },
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.consent, required this.endingSoon, required this.onWithdraw, required this.onRenew});

  final MarketingConsentView consent;
  final bool endingSoon;
  final VoidCallback onWithdraw;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = MaterialLocalizations.of(context).formatMediumDate;
    final active = consent.status == 'active';
    final status = switch (consent.status) {
      'active' => 'Until ${date(consent.endsAt.toLocal())}',
      'withdrawn' => 'Withdrawn ${consent.withdrawnAt != null ? date(consent.withdrawnAt!.toLocal()) : ''}'.trim(),
      'expired' => 'Ended ${date(consent.endsAt.toLocal())}',
      final other => other,
    };
    return RCard(
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: consent.thumbnailUrl == null ? const ColoredBox(color: Colors.black12) : Image(image: DiskCachedImage(consent.thumbnailUrl!), fit: BoxFit.cover),
          ),
          const SizedBox(width: RSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: theme.textTheme.bodyMedium),
                Text('Photo by ${consent.photographerCredit}', style: theme.textTheme.bodySmall),
                if (endingSoon) Text('Ends soon', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
          ),
          if (active && endingSoon) TextButton(onPressed: onRenew, child: const Text('Renew')),
          if (active) TextButton(onPressed: onWithdraw, child: const Text('Withdraw')),
        ],
      ),
    );
  }
}
