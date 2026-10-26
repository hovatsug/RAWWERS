import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/pro_listing_preview_response.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_section_label.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/dashboard/needs_you.dart';
import 'package:rawwers/features/pro/dashboard/next_shoot.dart';
import 'package:rawwers/features/pro/dashboard/you_band.dart';
import 'package:rawwers/features/pro/findings/findings_card.dart';
import 'package:rawwers/features/pro/interview/interview_controller.dart';
import 'package:rawwers/features/pro/dashboard/dashboard_controller.dart';
import 'package:rawwers/features/pro/listing/listing_preview_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/pro/tier/tier_section.dart';
import 'package:rawwers/features/shared/discover/discover_card.dart';
import 'package:rawwers/features/pro/available_now/available_now_card.dart';

/// The pro app's home: a photographer's own public identity, not a menu.
///
/// The inversion this replaces: the old home screen answered "what am I
/// shooting today", which on most days is nothing, and everything a
/// photographer actually maintains - their card, their photos, their prices,
/// their standing - sat two taps down under Settings. Here the listing card is
/// the hero, because it is the thing a client actually sees, and everything
/// below it is the evidence behind that card.
///
/// Kit is deliberately not a section. It changes rarely, nobody needs it on
/// their home screen, and it was the section most likely to make this read as
/// a menu with pictures. It lives behind Settings, with its full editor
/// unchanged.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    required this.settingsPath,
    required this.profilePath,
    required this.portfolioPath,
    required this.pricingPath,
    required this.availabilityPath,
    required this.listingPath,
    required this.onboardingPath,
    required this.interviewPath,
    required this.walletPath,
    super.key,
  });

  final String settingsPath;
  final String profilePath;
  final String portfolioPath;
  final String pricingPath;
  final String availabilityPath;
  final String listingPath;
  final String onboardingPath;
  final String interviewPath;
  final String walletPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // No app bar: the dark band is the top of this screen, under the
      // status bar, and carries the brand, the date and settings.
      body: RefreshIndicator(
        // One refresh for the whole screen. Every block reads a shared
        // provider, so a pull here is one round of calls rather than seven.
        onRefresh: () => ref.read(dashboardControllerProvider.notifier).refreshAll(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            YouBand(walletPath: walletPath, settingsPath: settingsPath),
            Padding(
              padding: const EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Findings first when there are any: a pause or a finding to
              // answer matters more than anything below it.
              const FindingsCard(),
              const AvailableNowCard(),
              const SizedBox(height: RSpace.s24),

              _Section(
                title: 'Where you stand',
                subtitle: 'Per niche, and what moves you up',
                child: TierSection(chooseNichesPath: portfolioPath),
              ),
              const SizedBox(height: RSpace.s24),

              const _Section(title: 'Next shoot', subtitle: 'The soonest shoot you have booked', child: NextShootCard()),
              const SizedBox(height: RSpace.s24),

              const _Section(title: 'Needs you', subtitle: 'Most urgent first', child: NeedsYou()),
              const SizedBox(height: RSpace.s24),

              const _Identity(),
              const SizedBox(height: RSpace.s24),

              _Section(
                title: 'Your card',
                subtitle: 'Exactly what a client sees',
                actionLabel: 'Open',
                onAction: () => context.push(listingPath),
                child: _ListingBlock(onboardingPath: onboardingPath, pricingPath: pricingPath, profilePath: profilePath),
              ),
              const SizedBox(height: RSpace.s24),

              _Section(
                title: 'Meet the photographer',
                subtitle: 'Optional: a few answers in your own words',
                actionLabel: 'Edit',
                onAction: () => context.push(interviewPath),
                child: const _InterviewBlock(),
              ),
              const SizedBox(height: RSpace.s24),

              _Section(
                title: 'Portfolio',
                subtitle: 'The photos clients judge you on',
                actionLabel: 'Edit',
                onAction: () => context.push(portfolioPath),
                child: const _PortfolioBlock(),
              ),
              const SizedBox(height: RSpace.s24),

              _Section(
                title: 'Pricing',
                subtitle: 'What you charge',
                actionLabel: 'Edit',
                onAction: () => context.push(pricingPath),
                child: const _PricingBlock(),
              ),
              const SizedBox(height: RSpace.s24),

              _Section(
                title: 'Availability',
                subtitle: 'When you can be booked',
                actionLabel: 'Edit',
                onAction: () => context.push(availabilityPath),
                child: const _AvailabilityBlock(),
              ),
              const SizedBox(height: RSpace.s32),

              Center(
                child: RTextLinkRow(label: 'Settings', onPressed: () => context.push(settingsPath)),
              ),
              const SizedBox(height: RSpace.s24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Name, headline, where they work. The one identity edit worth doing without
/// leaving: whether they are taking bookings at all.
class _Identity extends ConsumerWidget {
  const _Identity();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(proProfileControllerProvider);

    return switch (profile) {
      AsyncLoading() => const RSkeleton(height: 96),
      AsyncError() => RCard(
          child: Text('Could not load your profile.', style: theme.textTheme.bodyMedium),
        ),
      AsyncData(:final ProProfileView value) => RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value.displayName ?? 'Your name', style: theme.textTheme.headlineSmall),
              if (value.headline != null && value.headline!.isNotEmpty) ...[
                const SizedBox(height: RSpace.s4),
                Text(value.headline!, style: theme.textTheme.bodyMedium),
              ],
              if (_place(value) != null) ...[
                const SizedBox(height: RSpace.s4),
                Text(_place(value)!, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: RSpace.s12),
              _BookableState(accepting: value.isAcceptingBookings),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  static String? _place(ProProfileView profile) {
    final parts = [profile.city, profile.country].where((p) => p != null && p.isNotEmpty).cast<String>();
    if (parts.isEmpty) return null;
    final where = parts.join(', ');
    final radius = profile.travelRadiusKm;
    return radius == null ? where : '$where · travels up to ${radius}km';
  }
}

/// Whether clients can book at all.
///
/// Read-only on purpose. `is_accepting_bookings` is set true by
/// POST /v1/pro/me/activate and no endpoint sets it back, so a switch here
/// would be a control that cannot save - see docs/BACKEND_GAPS.md. Availability
/// is the lever that actually exists, so that is what this points at.
class _BookableState extends StatelessWidget {
  const _BookableState({required this.accepting});

  final bool accepting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          accepting ? Icons.check_circle_outline : Icons.pause_circle_outline,
          size: 18,
          color: accepting ? RDevelop.develop500 : theme.colorScheme.outline,
        ),
        const SizedBox(width: RSpace.s8),
        Expanded(
          child: Text(
            accepting
                ? 'Clients can book you. To stop, clear your working hours in Availability.'
                : 'Not bookable yet.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// The card a client sees, and what is keeping it hidden if it is.
class _ListingBlock extends ConsumerWidget {
  const _ListingBlock({
    required this.onboardingPath,
    required this.pricingPath,
    required this.profilePath,
  });

  final String onboardingPath;
  final String pricingPath;
  final String profilePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preview = ref.watch(listingPreviewControllerProvider);

    return switch (preview) {
      AsyncLoading() => const RSkeleton(height: 220),
      AsyncError() => RCard(child: Text('Could not load your card.', style: theme.textTheme.bodyMedium)),
      AsyncData(:final ProListingPreviewResponse value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                RStatusChip(
                  label: value.isLive ? 'Live' : 'Hidden',
                  kind: value.isLive ? RStatusChipKind.positive : RStatusChipKind.stopped,
                ),
                const SizedBox(width: RSpace.s8),
                if (value.availableDaysNext14 != null)
                  Expanded(
                    child: Text(
                      '${value.availableDaysNext14} bookable ${value.availableDaysNext14 == 1 ? 'day' : 'days'} in the next 14',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: RSpace.s12),
            DiscoverCard(card: value.card, onTap: () {}),
            if (!value.isLive && (value.blockingReasons?.isNotEmpty ?? false)) ...[
              const SizedBox(height: RSpace.s12),
              for (final reason in value.blockingReasons!)
                Padding(
                  padding: const EdgeInsets.only(bottom: RSpace.s4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.remove_circle_outline, size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: RSpace.s8),
                      Expanded(
                        child: Text(
                          blockingReasonDisplay(
                            reason,
                            onboardingPath: onboardingPath,
                            pricingPath: pricingPath,
                            profilePath: profilePath,
                          ).text,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PortfolioBlock extends ConsumerWidget {
  const _PortfolioBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final portfolio = ref.watch(portfolioControllerProvider);

    return switch (portfolio) {
      AsyncLoading() => const RSkeleton(height: 88),
      AsyncError() => RCard(child: Text('Could not load your portfolio.', style: theme.textTheme.bodyMedium)),
      AsyncData(:final value) => RCard(
          child: Row(
            children: [
              const Icon(Icons.photo_library_outlined),
              const SizedBox(width: RSpace.s12),
              Expanded(
                child: Text(
                  (value.items?.isEmpty ?? true)
                      ? 'No photos yet. Clients judge you on these first.'
                      : '${value.items!.length} ${value.items!.length == 1 ? 'photo' : 'photos'}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Price is read off the listing card rather than fetched again - it is the
/// same number a client sees, and two sources for one figure is how they end
/// up disagreeing.
class _PricingBlock extends ConsumerWidget {
  const _PricingBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preview = ref.watch(listingPreviewControllerProvider);

    return switch (preview) {
      AsyncLoading() => const RSkeleton(height: 72),
      AsyncData(:final ProListingPreviewResponse value) => RCard(
          child: Row(
            children: [
              const Icon(Icons.sell_outlined),
              const SizedBox(width: RSpace.s12),
              Expanded(
                child: Text(
                  value.card.minPrice == null
                      ? 'No price set, so your card says "price on request".'
                      // The cheapest complete booking, not the per-photo
                      // rate. Naming it plainly so a photographer is not
                      // surprised by what clients see.
                      : 'Clients see "from ${value.card.currency} ${value.card.minPrice}" '
                          'for your smallest booking',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      _ => const RSkeleton(height: 72),
    };
  }
}

class _AvailabilityBlock extends ConsumerWidget {
  const _AvailabilityBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preview = ref.watch(listingPreviewControllerProvider);

    return switch (preview) {
      AsyncLoading() => const RSkeleton(height: 72),
      AsyncData(:final ProListingPreviewResponse value) => RCard(
          child: Row(
            children: [
              const Icon(Icons.event_available_outlined),
              const SizedBox(width: RSpace.s12),
              Expanded(
                child: Text(
                  value.availableDaysNext14 == null
                      ? 'We could not work out your next two weeks.'
                      : value.availableDaysNext14 == 0
                          ? 'No bookable days in the next 14. Clients cannot book you.'
                          : '${value.availableDaysNext14} bookable days in the next 14',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      _ => const RSkeleton(height: 72),
    };
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(header: true, child: RSectionLabel(title)),
                  const SizedBox(height: RSpace.s4),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              RTextLinkRow(label: actionLabel!, onPressed: onAction!),
          ],
        ),
        const SizedBox(height: RSpace.s12),
        child,
      ],
    );
  }
}

/// A text action sized for a section header.
class RTextLinkRow extends StatelessWidget {
  const RTextLinkRow({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}


/// Where their interview stands, in one line. Never a nudge to rank higher:
/// it changes nothing about where they appear.
class _InterviewBlock extends ConsumerWidget {
  const _InterviewBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = switch (ref.watch(interviewControllerProvider)) {
      AsyncData(:final value) when !value.isPublished => 'Not on your profile. Clients see it only once you publish.',
      AsyncData(:final value) when value.hasUnpublishedChanges => 'On your profile, with changes not published yet.',
      AsyncData() => 'On your profile.',
      AsyncError() => 'Could not load it.',
      _ => '',
    };
    return Text(text, key: const ValueKey('interview-block'), style: theme.textTheme.bodyMedium);
  }
}
