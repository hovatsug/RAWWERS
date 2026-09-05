import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/pro_listing_preview_response.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/listing/listing_preview_controller.dart';
import 'package:rawwers/features/shared/discover/discover_card.dart';

/// What a client sees, shown to the photographer who owns it.
///
/// The card is the same widget the client app renders in Discover, fed by
/// the endpoint that builds the real feed. A preview assembled separately
/// would eventually flatter or misrepresent the listing, which is the one
/// thing it must never do.
class ListingPreviewScreen extends ConsumerWidget {
  const ListingPreviewScreen({
    required this.onboardingPath,
    required this.pricingPath,
    required this.profilePath,
    required this.portfolioPath,
    super.key,
  });

  final String onboardingPath;
  final String pricingPath;
  final String profilePath;
  final String portfolioPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(listingPreviewControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your listing')),
      body: SafeArea(
        child: switch (preview) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.read(listingPreviewControllerProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(RSpace.s16),
                children: [
                  _LiveBanner(preview: value),
                  const SizedBox(height: RSpace.s16),
                  Text(
                    'This is your card, exactly as a client sees it.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: RSpace.s12),
                  // Tapping does nothing here on purpose: it is a preview,
                  // and a card that navigated would suggest otherwise.
                  DiscoverCard(card: value.card, onTap: () {}),
                  const SizedBox(height: RSpace.s24),
                  _WhatFeedsIt(
                    preview: value,
                    pricingPath: pricingPath,
                    profilePath: profilePath,
                    portfolioPath: portfolioPath,
                  ),
                ],
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your listing.',
              onRetry: () => ref.invalidate(listingPreviewControllerProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: 240), SizedBox(height: RSpace.s16), RSkeleton(width: 300)],
              ),
            ),
        },
      ),
    );
  }
}

class _LiveBanner extends ConsumerWidget {
  const _LiveBanner({required this.preview});

  final ProListingPreviewResponse preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  preview.isLive ? 'Clients can find you' : 'Not visible to clients yet',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              RStatusChip(
                label: preview.isLive ? 'Live' : 'Hidden',
                kind: preview.isLive ? RStatusChipKind.positive : RStatusChipKind.inProgress,
              ),
            ],
          ),
          if (preview.availableDaysNext14 != null) ...[
            const SizedBox(height: RSpace.s8),
            Text(
              'Free on ${preview.availableDaysNext14} of the next 14 days.',
              style: theme.textTheme.bodySmall,
            ),
          ] else ...[
            const SizedBox(height: RSpace.s8),
            // Null means no weekly hours at all, which is a different thing
            // from being fully booked and should not read as zero.
            Text('You have not set any working hours.', style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _WhatFeedsIt extends StatelessWidget {
  const _WhatFeedsIt({
    required this.preview,
    required this.pricingPath,
    required this.profilePath,
    required this.portfolioPath,
  });

  final ProListingPreviewResponse preview;
  final String pricingPath;
  final String profilePath;
  final String portfolioPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reasons = preview.blockingReasons ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reasons.isNotEmpty) ...[
          Text('What is keeping it hidden', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s12),
          for (final reason in reasons)
            Padding(
              padding: const EdgeInsets.only(bottom: RSpace.s8),
              child: _ReasonRow(
                reason: reason,
                pricingPath: pricingPath,
                profilePath: profilePath,
              ),
            ),
          const SizedBox(height: RSpace.s24),
        ],
        Text('What shapes this card', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s12),
        // Named so the connection is visible: the brief for this screen is
        // that editing pricing should visibly change the card, and a pro
        // should be able to see which lever moves which part.
        _FeedsRow(
          label: 'Cover photo and photo count',
          detail: 'From your portfolio',
          onTap: () => context.go(portfolioPath),
        ),
        _FeedsRow(
          label: 'Price range',
          detail: 'The cheapest and dearest of your packages',
          onTap: () => context.go(pricingPath),
        ),
        _FeedsRow(
          label: 'Name, headline and city',
          detail: 'From your profile',
          onTap: () => context.go(profilePath),
        ),
      ],
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.reason, required this.pricingPath, required this.profilePath});

  final String reason;
  final String pricingPath;
  final String profilePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = blockingReasonDisplay(
      reason,
      onboardingPath: '',
      pricingPath: pricingPath,
      profilePath: profilePath,
    );

    return RCard(
      child: Row(
        children: [
          Expanded(child: Text(display.text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _FeedsRow extends StatelessWidget {
  const _FeedsRow({required this.label, required this.detail, required this.onTap});

  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: RSpace.s12),
      child: RCard(
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: RSpace.s4),
                    Text(detail, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
