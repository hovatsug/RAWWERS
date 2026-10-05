import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/client_portfolio_item.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/api/models/client_profile_niche.dart';
import 'package:rawwers/design/components/r_tier_badge.dart';
import 'package:rawwers/design/components/r_package_price.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/shared/reviews/review_display.dart';
import 'package:rawwers/features/shared/reviews/pro_reviews_controller.dart';
import 'package:rawwers/features/client/discover/discover_controller.dart';
import 'package:rawwers/features/client/booking_request/booking_request_sheet.dart';
import 'package:rawwers/features/client/discover/widgets/location_prompt.dart';
import 'package:rawwers/features/client/pro_profile/availability_calendar.dart';
import 'package:rawwers/features/client/pro_profile/availability_controller.dart';
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

/// A photographer's public profile.
///
/// Stateful only because of the niche filter. Everything else here renders
/// what the server sent - which niches exist, in what order, and the tier
/// held in each are all decided server-side, because they are claims about a
/// photographer rather than presentation.
class _Profile extends StatefulWidget {
  const _Profile({required this.profile});

  final ClientProProfileResponse profile;

  @override
  State<_Profile> createState() => _ProfileState();
}

class _ProfileState extends State<_Profile> {
  /// Null means every niche. A multi-niche profile opens on everything rather
  /// than on the busiest niche: defaulting to a filter would hide most of a
  /// portfolio behind a control the client has not touched yet.
  String? _niche;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final theme = Theme.of(context);
    final name = profile.displayName ?? 'Photographer';
    final allPhotos = profile.portfolioPreview ?? const <ClientPortfolioItem>[];
    final packages = profile.packages ?? const <ClientProfilePackage>[];

    // Empty for a single-niche photographer. The server sends nothing rather
    // than one entry, so there is no selector to suppress here.
    final niches = profile.niches ?? const <ClientProfileNiche>[];
    final selected = _niche == null
        ? null
        : niches.where((n) => n.slug == _niche).firstOrNull;

    final portfolio = selected == null
        ? allPhotos
        : allPhotos.where((p) => (p.nicheSlugs ?? const []).contains(selected.slug)).toList();

    // What this photographer says about the niche being viewed, falling back
    // to their general bio. Never an empty section: a tab that renders
    // nothing reads as a loading failure.
    final about = selected?.description?.isNotEmpty == true ? selected!.description! : profile.bio;

    return RefreshIndicator(
      // Everything on the profile that changes as people book and review.
      onRefresh: () async {
        final container = ProviderScope.containerOf(context);
        container.invalidate(proProfileProvider(profile.proUserId));
        container.invalidate(proReviewsProvider(profile.proUserId));
        container.invalidate(proAvailabilityProvider);
      },
      child: CustomScrollView(
        // A short profile still pulls to refresh.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: RNetworkPhoto(
                url: profile.coverUrl,
                semanticLabel: '$name cover photo',
              ),
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
                if (about != null && about.isNotEmpty) ...[
                  const SizedBox(height: RSpace.s16),
                  Text(about, style: theme.textTheme.bodyMedium),
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
          if (niches.length > 1)
            SliverPadding(
              padding: const EdgeInsets.only(top: RSpace.s8),
              sliver: SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: RSpace.s16),
                  child: Row(
                    children: [
                      RFilterChip(
                        label: 'All',
                        selected: _niche == null,
                        onPressed: () => setState(() => _niche = null),
                      ),
                      for (final niche in niches) ...[
                        const SizedBox(width: RSpace.s8),
                        RFilterChip(
                          label: niche.name,
                          selected: _niche == niche.slug,
                          onPressed: () => setState(() => _niche = niche.slug),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          if (portfolio.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                RSpace.s16,
                RSpace.s16,
                RSpace.s16,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected == null
                            ? 'Recent work'
                            : '${selected.name} work',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    // Tier is per-niche, so it appears only when a niche is
                    // being viewed. Shown on the whole-portfolio view it would
                    // have to pick one niche's tier and present it as the
                    // photographer's, which is the flat claim the per-niche
                    // model exists to replace.
                    // Always something, never nothing. Tier is the signal the
                    // whole pricing-cap and ranking system rests on, and it was
                    // invisible on every profile: withheld entirely for
                    // single-niche photographers, and shown for the rest only
                    // after a tab was tapped, which the default view never is.
                    //
                    // On the whole-portfolio view it names its niche, because a
                    // bare tier there would be the flat claim the per-niche
                    // model exists to replace.
                    if (selected == null && niches.isNotEmpty)
                      Text(
                        '${rTierName(niches.first.tier)} in ${niches.first.name}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (selected != null)
                      Text(
                        rTierName(selected.tier),
                        // Not `outline`: that is the card's border colour and
                        // renders at 1.11:1 on the fill. Same mistake as the
                        // starting-total line, made again hours later, which is
                        // why the contrast suite now covers text on a card.
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
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
            padding: const EdgeInsets.fromLTRB(
              RSpace.s16,
              0,
              RSpace.s16,
              RSpace.s32,
            ),
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
                    _PackageCard(
                      package: package,
                      proUserId: profile.proUserId,
                      proName: name,
                      defaultLocation: profile.city,
                    ),
                    const SizedBox(height: RSpace.s12),
                  ],
              ],
            ),
          ),
          if (packages.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                RSpace.s16,
                0,
                RSpace.s16,
                RSpace.s32,
              ),
              sliver: SliverToBoxAdapter(
                child: _WhenTheyAreFree(
                  proUserId: profile.proUserId,
                  proName: name,
                  packages: packages,
                  defaultLocation: profile.city,
                ),
              ),
            ),
          // Only once the profile says there are reviews. With none, the
          // "No reviews yet" line under the name already says so, and an empty
          // heading here would read as a list that failed to load.
          if (profile.reviewCount > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                RSpace.s16,
                0,
                RSpace.s16,
                RSpace.s32,
              ),
              sliver: SliverToBoxAdapter(
                child: _Reviews(proUserId: profile.proUserId),
              ),
            ),
        ],
      ),
    );
  }
}

/// The photographer's real availability, for one package at a time.
///
/// Per package because a start time depends on how long the shoot is: a
/// three-hour package cannot start where only an hour is free. Picking a time
/// opens the request with that time already in it.
class _WhenTheyAreFree extends StatefulWidget {
  const _WhenTheyAreFree({
    required this.proUserId,
    required this.proName,
    required this.packages,
    this.defaultLocation,
  });

  final String proUserId;
  final String proName;
  final List<ClientProfilePackage> packages;
  final String? defaultLocation;

  @override
  State<_WhenTheyAreFree> createState() => _WhenTheyAreFreeState();
}

class _WhenTheyAreFreeState extends State<_WhenTheyAreFree> {
  late ClientProfilePackage _package = widget.packages.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("When they're free", style: theme.textTheme.titleMedium),
        if (widget.packages.length > 1) ...[
          const SizedBox(height: RSpace.s8),
          Wrap(
            spacing: RSpace.s8,
            runSpacing: RSpace.s8,
            children: [
              for (final package in widget.packages)
                RFilterChip(
                  label: package.title,
                  selected: package.id == _package.id,
                  onPressed: () => setState(() => _package = package),
                ),
            ],
          ),
        ],
        const SizedBox(height: RSpace.s12),
        AvailabilityCalendar(
          // A different package is a different calendar - start it fresh.
          key: ValueKey(_package.id),
          proUserId: widget.proUserId,
          proName: widget.proName,
          packageId: _package.id,
          onPick: (pick) => _openBookingRequest(
            context,
            proUserId: widget.proUserId,
            proName: widget.proName,
            package: _package,
            defaultLocation: widget.defaultLocation,
            initialPick: pick,
          ),
        ),
      ],
    );
  }
}

/// What clients who booked this photographer said.
class _Reviews extends ConsumerWidget {
  const _Reviews({required this.proUserId});

  final String proUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviews = ref.watch(proReviewsProvider(proUserId));

    return switch (reviews) {
      // The count on the profile can run ahead of the list - a review hidden
      // since the index was built. Nothing to show is then nothing, not an
      // empty section.
      AsyncData(:final value) when value.items.isEmpty =>
        const SizedBox.shrink(),
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s12),
          for (final review in value.items) ...[
            RCard(child: ReviewContent.public(review)),
            const SizedBox(height: RSpace.s12),
          ],
          if (value.total > value.items.length)
            Text(
              'Showing the ${value.items.length} most recent of ${value.total} reviews.',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
      AsyncError() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          Text('Could not load reviews.', style: theme.textTheme.bodyMedium),
          RTextLink(
            label: 'Try again',
            onPressed: () => ref.invalidate(proReviewsProvider(proUserId)),
          ),
        ],
      ),
      _ => const RSkeleton(height: 96),
    };
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
  const _PackageCard({
    required this.package,
    required this.proUserId,
    required this.proName,
    this.defaultLocation,
  });

  final ClientProfilePackage package;
  final String proUserId;
  final String proName;
  final String? defaultLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(package.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s8),
          // The per-photo rate leads. This used to render package.price beside
          // the title as though it were the package price - but that field is
          // the entry rate, so the card advertised EUR 243 for work that
          // charges EUR 6,075.
          RPackagePrice(
            entryRate: package.entryRate,
            minimumPhotos: package.minimumPhotos,
            startingTotal: package.startingTotal,
            currency: package.currency,
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

  Future<void> _requestBooking(BuildContext context) => _openBookingRequest(
    context,
    proUserId: proUserId,
    proName: proName,
    package: package,
    defaultLocation: defaultLocation,
  );
}

/// The booking sheet, from a package card or from a time picked on the
/// calendar - then the booking it created.
Future<void> _openBookingRequest(
  BuildContext context, {
  required String proUserId,
  required String proName,
  required ClientProfilePackage package,
  String? defaultLocation,
  PickedStart? initialPick,
}) async {
  final bookingId = await showBookingRequestSheet(
    context,
    proUserId: proUserId,
    proName: proName,
    package: package,
    defaultLocation: defaultLocation,
    initialPick: initialPick,
  );
  if (bookingId == null || !context.mounted) return;

  // Straight to the booking rather than a toast: the client's next question
  // is "did that work, and what happens now", which the booking answers and
  // a snackbar does not. Pushed onto Discover's stack, so back returns to
  // the profile they were reading.
  final container = ProviderScope.containerOf(context);
  await context.push(ClientRoute.bookingDetail(bookingId));
  // Back on the profile, the calendar asks again: other clients may have
  // booked while this one looked at their booking.
  container.invalidate(proAvailabilityProvider);
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
