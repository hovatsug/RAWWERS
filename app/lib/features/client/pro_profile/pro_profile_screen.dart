import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_portfolio_item.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/discover/discover_controller.dart';
import 'package:rawwers/features/client/discover/widgets/location_prompt.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_controller.dart';

/// One photographer, in enough depth to decide whether to book them.
///
/// Ordered the way the decision is actually made: the work first, then who
/// they are, then what it costs. Packages are last but are the only
/// actionable thing on the page.
class ProProfileScreen extends ConsumerWidget {
  const ProProfileScreen({required this.proUserId, super.key});

  final String proUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(proProfileProvider(proUserId));

    return Scaffold(
      body: switch (profile) {
        AsyncLoading() => const _ProfileSkeleton(),
        AsyncError(:final error) when error is LocationNotSet => const SafeArea(child: LocationPrompt()),
        AsyncError(:final error) => SafeArea(
            child: RErrorState(
              message: pagingFailureMessage(error),
              onRetry: () => ref.invalidate(proProfileProvider(proUserId)),
            ),
          ),
        AsyncData(:final value) => _Profile(profile: value),
        _ => const _ProfileSkeleton(),
      },
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.profile});

  final ClientProProfileResponse profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile.displayName ?? 'Photographer';
    final portfolio = profile.portfolioPreview ?? const <ClientPortfolioItem>[];
    final packages = profile.packages ?? const <ClientProfilePackage>[];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: RNetworkPhoto(url: profile.coverUrl, semanticLabel: '$name cover photo'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(RSpace.s16),
          sliver: SliverList.list(
            children: [
              Text(name, style: theme.textTheme.headlineSmall),
              if (profile.headline != null) ...[
                const SizedBox(height: RSpace.s4),
                Text(profile.headline!, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: RSpace.s8),
              _Meta(profile: profile),
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: RSpace.s16),
                Text(profile.bio!, style: theme.textTheme.bodyMedium),
              ],
              if ((profile.styles ?? const []).isNotEmpty) ...[
                const SizedBox(height: RSpace.s16),
                // A text line, not chips: these are descriptive labels, and
                // the design system's chips are either status (RStatusChip)
                // or interactive filters (RFilterChip). Dressing a plain
                // label as either would misread as something you can act on.
                Text(
                  profile.styles!.map(_humanise).join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (portfolio.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: RSpace.s16),
            sliver: SliverToBoxAdapter(
              child: Text('Recent work', style: theme.textTheme.titleMedium),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(RSpace.s16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: RSpace.s4,
                crossAxisSpacing: RSpace.s4,
              ),
              itemCount: portfolio.length,
              itemBuilder: (context, index) => RNetworkPhoto(
                url: portfolio[index].thumbnailUrl,
                semanticLabel: 'Portfolio photo ${index + 1} by $name',
              ),
            ),
          ),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(RSpace.s16, 0, RSpace.s16, RSpace.s32),
          sliver: SliverList.list(
            children: [
              Text('Packages', style: theme.textTheme.titleMedium),
              const SizedBox(height: RSpace.s12),
              if (packages.isEmpty)
                Text(
                  '$name has no packages listed right now.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                for (final package in packages) ...[
                  _PackageCard(package: package, proUserId: profile.proUserId, proName: name),
                  const SizedBox(height: RSpace.s12),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.profile});

  final ClientProProfileResponse profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = [profile.city, profile.country].whereType<String>().where((part) => part.isNotEmpty).join(', ');

    return Row(
      children: [
        if (profile.reviewCount > 0) ...[
          const Icon(Icons.star, size: 16),
          const SizedBox(width: RSpace.s4),
          Text(
            profile.avgRating,
            style: theme.textTheme.bodySmall?.copyWith(fontFeatures: RType.tabularFigures),
          ),
          Text(
            ' (${profile.reviewCount})',
            style: theme.textTheme.bodySmall,
          ),
        ] else
          Text('No reviews yet', style: theme.textTheme.bodySmall),
        if (place.isNotEmpty) ...[
          const SizedBox(width: RSpace.s12),
          Flexible(child: Text(place, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
        ],
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.proUserId, required this.proName});

  final ClientProfilePackage package;
  final String proUserId;
  final String proName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(package.title, style: theme.textTheme.titleSmall)),
              const SizedBox(width: RSpace.s8),
              // Money is a decimal string from the API and stays one all the
              // way to the screen.
              Text(
                '€${package.price}',
                style: theme.textTheme.titleSmall?.copyWith(fontFeatures: RType.tabularFigures),
              ),
            ],
          ),
          if (package.description != null && package.description!.isNotEmpty) ...[
            const SizedBox(height: RSpace.s4),
            Text(package.description!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: RSpace.s12),
          Text(
            '${_duration(package.durationMinutes)} · ${package.includedPhotos} photos included',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: RSpace.s4),
          Text(
            'Proofs in ${package.proofsSlaDays} days, finals in ${package.finalsSlaDays}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: RSpace.s16),
          RButton(
            label: 'Request this package',
            onPressed: () => _requestBooking(context),
          ),
        ],
      ),
    );
  }

  void _requestBooking(BuildContext context) {
    // Wired to the booking request flow in the Bookings step of F-7.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking requests are coming next.')),
    );
  }
}

String _duration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  final hourLabel = hours == 1 ? '1 hour' : '$hours hours';
  return rest == 0 ? hourLabel : '$hourLabel $rest min';
}

String _humanise(String slug) {
  return slug
      .split(RegExp('[-_]'))
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: PagedListSkeleton());
  }
}
