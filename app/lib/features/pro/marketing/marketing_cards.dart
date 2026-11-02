import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/components/r_switch_tile.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/marketing/marketing_controllers.dart';

/// A switch's onChanged that saves and, if that fails, says why. The
/// messenger is taken before the save, while the context is current.
ValueChanged<bool> _saving(BuildContext context, Future<String?> Function(bool on) save) => (on) async {
      final messenger = ScaffoldMessenger.of(context);
      final problem = await save(on);
      if (problem != null) messenger.showSnackBar(SnackBar(content: Text(problem)));
    };

/// Settings: the marketing clause of the photographer's agreement.
class MarketingAgreementCard extends ConsumerWidget {
  const MarketingAgreementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final agreement = ref.watch(marketingAgreementControllerProvider);
    return switch (agreement) {
      AsyncData(:final value) => RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RSwitchTile(
                title: 'Let RAWWERS feature my work',
                subtitle: Text(
                  value.optedIn
                      ? 'Your clients may be asked whether RAWWERS can show their photos, always credited to you.'
                      : 'Off: your clients are not asked.',
                  style: theme.textTheme.bodySmall,
                ),
                value: value.optedIn,
                onChanged: _saving(context, ref.read(marketingAgreementControllerProvider.notifier).set),
              ),
              const SizedBox(height: RSpace.s8),
              Text(value.wordingText, style: theme.textTheme.bodySmall),
              if (value.recordedAt case final at?) ...[
                const SizedBox(height: RSpace.s4),
                Text(
                  'Last changed ${MaterialLocalizations.of(context).formatMediumDate(at.toLocal())} (wording ${value.wordingVersion}).',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      AsyncError() => RCard(child: Text('Could not load your marketing setting.', style: theme.textTheme.bodySmall)),
      _ => const RCard(child: RSkeleton(width: RSize.lineMedium)),
    };
  }
}

/// A booking's switches, on the screen where its photos are delivered.
class BookingMarketingCard extends ConsumerWidget {
  const BookingMarketingCard({required this.gigId, super.key});

  final String gigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(bookingMarketingControllerProvider(gigId));
    final controller = ref.read(bookingMarketingControllerProvider(gigId).notifier);
    return switch (settings) {
      AsyncData(:final value) => RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('RAWWERS marketing', style: theme.textTheme.titleSmall),
              const SizedBox(height: RSpace.s4),
              Text(
                switch (value) {
                  _ when value.locked => 'The client has given permission for some photos, so these are fixed.',
                  _ when !value.optedIn => 'Turn on "Let RAWWERS feature my work" in Settings for clients to be asked.',
                  _ => 'After rating you, the client may be asked whether RAWWERS can feature their photos.',
                },
                style: theme.textTheme.bodySmall,
              ),
              RSwitchTile(
                title: 'Allow marketing use',
                value: value.allowMarketing,
                onChanged: value.locked || !value.optedIn
                    ? null
                    : _saving(context, (on) => controller.set(allowMarketing: on)),
              ),
              RSwitchTile(
                title: 'Includes children',
                subtitle: Text('The client is never asked for a booking with children in it.', style: theme.textTheme.bodySmall),
                value: value.includesChildren,
                onChanged: value.locked ? null : _saving(context, (on) => controller.set(includesChildren: on)),
              ),
            ],
          ),
        ),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }
}
