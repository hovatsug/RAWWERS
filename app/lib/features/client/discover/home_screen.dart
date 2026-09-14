import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_niche_tile.dart';
import 'package:rawwers/design/components/r_package_price.dart';
import 'package:rawwers/design/components/r_tier_badge.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/discover/home_controller.dart';
import 'package:rawwers/features/client/discover/widgets/hero_carousel.dart';
import 'package:rawwers/features/client/discover/hero_slides.dart';

/// Browsing photographers the way people browse things they might want.
///
/// Rows arrive composed, titled and ordered by the server. The screen renders
/// what it is given and decides nothing about membership - the fairness rules
/// live in one place, and a second opinion here is how two implementations of
/// one rule start to drift.
///
/// A niche row is headed by a photograph from that niche rather than a text
/// chip. The image is the first card's cover, which by construction is the
/// top-ranked photographer in that niche in this city - so the tile is a live
/// sample of the marketplace's own inventory rather than a category
/// illustration, and it cannot go stale the way a curated asset would.
class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({this.onOpenPro, this.onOpenNiche, super.key});

  final void Function(String proUserId)? onOpenPro;
  final void Function(String nicheSlug)? onOpenNiche;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(homeControllerProvider);

    return switch (rows) {
      // Not the same as an empty city, and deliberately worded so.
      AsyncData(value: HomeNeedsLocation()) => const REmptyState(
          title: 'Where are you looking?',
          body: 'Choose a city and we will show you the photographers working there.',
          icon: Icons.location_on_outlined,
        ),
      AsyncData(value: HomeRows(:final rows)) when rows.isEmpty => const REmptyState(
          title: 'No photographers here yet',
          body: 'Nobody is taking bookings in this city at the moment. Try another one.',
          icon: Icons.photo_camera_outlined,
        ),
      AsyncData(value: HomeRows(rows: final value)) => _Rows(
          rows: value,
          onOpenPro: onOpenPro,
          onOpenNiche: onOpenNiche,
          onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        ),
      AsyncError() => RErrorState(
          message: 'Could not load photographers.',
          onRetry: () => ref.invalidate(homeControllerProvider),
        ),
      _ => const _LoadingRows(),
    };
  }
}

/// The loaded home: a hero, then the rows.
///
/// The hero is the first item of the same list rather than a separate widget
/// above it, so it scrolls away with everything else instead of pinning a
/// third of the screen in place.
class _Rows extends StatelessWidget {
  const _Rows({
    required this.rows,
    required this.onRefresh,
    this.onOpenPro,
    this.onOpenNiche,
  });

  final List<ClientHomeRow> rows;
  final Future<void> Function() onRefresh;
  final void Function(String proUserId)? onOpenPro;
  final void Function(String nicheSlug)? onOpenNiche;

  @override
  Widget build(BuildContext context) {
    final slides = heroSlidesFrom(rows);
    final hasHero = slides.isNotEmpty;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        // The first row's heading sits directly under the status bar without
        // this - the clock draws straight through it. The list scrolls under
        // the status bar by design, so the inset belongs on the content
        // rather than on a SafeArea wrapper, which would clip the scroll
        // instead of padding it.
        //
        // The hero is the exception: it is a photograph and is meant to run
        // under the clock, so when one is present the inset moves off the
        // list and onto the rows beneath it.
        padding: EdgeInsets.only(
          top: hasHero ? 0 : MediaQuery.paddingOf(context).top + RSpace.s8,
          bottom: RSpace.s32,
        ),
        itemCount: rows.length + (hasHero ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasHero && index == 0) {
            return HeroCarousel(
              slides: slides,
              // The niche's own page does not exist yet, so a slide opens the
              // photographer it is showing. The slide carries its nicheSlug
              // for when that page lands.
              onOpen: (slide) => onOpenPro?.call(slide.card.proUserId),
            );
          }
          return _Row(
            row: rows[index - (hasHero ? 1 : 0)],
            onOpenPro: onOpenPro,
            onOpenNiche: onOpenNiche,
          );
        },
      ),
    );
  }
}


/// Geometry shared by a loaded row and the placeholder that stands in for it.
///
/// These used to be two independent sets of numbers. The placeholder drew a
/// 148pt row with no side padding of its own; the loaded row is 208pt and
/// bleeds to the screen edge. So every row on the home screen grew by 60pt
/// and shifted sideways the instant content arrived, which reads as broken
/// however correct the rest of the screen is.
///
/// A placeholder's whole job is to occupy the space its content will occupy.
/// Naming the numbers once is what stops the two drifting apart again.
abstract final class _RowMetrics {
  static const cardWidth = 148.0;
  static const coverSize = 148.0;

  /// Cover, gap, name, then the rate and the total it produces. 208 fitted
  /// a name and one price line; the rate needs a line of its own, and a card
  /// that clips its own price is worse than one that is a little taller.
  static const rowHeight = 224.0;

  static const gap = RSpace.s12;
  static const sidePadding = EdgeInsets.symmetric(horizontal: RSpace.s16);
  static const headingPadding = EdgeInsets.fromLTRB(RSpace.s16, RSpace.s24, RSpace.s16, RSpace.s8);
  static const headingHeight = 20.0;
  static const headingWidth = 180.0;
}


class _Row extends StatelessWidget {
  const _Row({required this.row, this.onOpenPro, this.onOpenNiche});

  final ClientHomeRow row;
  final void Function(String proUserId)? onOpenPro;
  final void Function(String nicheSlug)? onOpenNiche;

  /// Niche rows carry a slug in their key ("niche:weddings"); the popularity
  /// rows do not. Read from the key rather than inferred from the title,
  /// because the title is prose meant for a person and will be translated.
  String? get _nicheSlug => row.key.startsWith('niche:') ? row.key.substring(6) : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slug = _nicheSlug;
    // The server omits empty rows entirely, so this should never be empty -
    // but `items` is nullable on the wire, and rendering a row that turned
    // out to have nothing is worse than rendering none.
    final items = row.items ?? const <ClientDiscoverCard>[];
    if (items.isEmpty) return const SizedBox.shrink();
    final leadCover = items.first.coverUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _RowMetrics.headingPadding,
          child: slug == null
              ? _RowHeading(title: row.title, subtitle: row.subtitle)
              : RNicheTile(
                  label: row.title,
                  imageUrl: leadCover,
                  width: double.infinity,
                  height: 96,
                  onTap: onOpenNiche == null ? null : () => onOpenNiche!(slug),
                ),
        ),
        SizedBox(
          height: _RowMetrics.rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: _RowMetrics.sidePadding,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: _RowMetrics.gap),
            itemBuilder: (context, index) => _Card(
              card: items[index],
              onTap: onOpenPro == null ? null : () => onOpenPro!(items[index].proUserId),
            ),
          ),
        ),
        if (row.subtitle != null && slug != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s8, RSpace.s16, 0),
            child: Text(row.subtitle!, style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _RowHeading extends StatelessWidget {
  const _RowHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: RSpace.s4),
          Text(subtitle!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.card, this.onTap});

  final ClientDiscoverCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: _RowMetrics.cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _RowMetrics.coverSize,
              width: _RowMetrics.coverSize,
              child: RNetworkPhoto(url: card.coverUrl, semanticLabel: card.displayName),
            ),
            const SizedBox(height: RSpace.s8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.displayName ?? 'Photographer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (rTierBadgeFor(card) case final tier?) ...[
                  const SizedBox(width: RSpace.s4),
                  RTierLabel(tier: tier),
                ],
              ],
            ),
            // Price is the second thing anyone wants and the first thing that
            // must not be invented: a null price renders as nothing rather
            // than as a zero, which would read as free.
            //
            // The rate leads, as it does on the profile. A card showing only
            // a total gives a large bare number with no unit - the same
            // misrepresentation the profile card was fixed for. The rate is
            // null until the index row has been recomputed since the column
            // landed, and then the total alone is still better than a guess.
            if (card.minEntryRate != null && card.minPrice != null)
              RPackagePrice(
                entryRate: card.minEntryRate!,
                minimumPhotos: card.minEntryPhotos ?? 0,
                startingTotal: card.minPrice!,
                currency: card.currency,
                density: RPackagePriceDensity.card,
              )
            else if (card.minPrice != null)
              Text(
                'from ${card.currency} ${card.minPrice}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingRows extends StatelessWidget {
  const _LoadingRows();

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Matches the loaded list's own insets, so the first heading does not
      // move down the moment rows arrive.
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + RSpace.s8,
        bottom: RSpace.s32,
      ),
      children: [
        for (var row = 0; row < 3; row++) ...[
          const Padding(
            padding: _RowMetrics.headingPadding,
            child: RSkeleton(width: _RowMetrics.headingWidth, height: _RowMetrics.headingHeight),
          ),
          SizedBox(
            height: _RowMetrics.rowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: _RowMetrics.sidePadding,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: _RowMetrics.gap),
              itemBuilder: (context, index) => const _CardSkeleton(),
            ),
          ),
        ],
      ],
    );
  }
}


/// The shape of a card before it has loaded: cover, then the name line.
///
/// Built from the same metrics as the real card so the two occupy the same
/// box. A single full-height block would fill the space without standing in
/// for anything, and would jump differently once text arrived.
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: _RowMetrics.cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RSkeleton(width: _RowMetrics.coverSize, height: _RowMetrics.coverSize),
          SizedBox(height: RSpace.s8),
          RSkeleton(width: 96, height: 12),
        ],
      ),
    );
  }
}
