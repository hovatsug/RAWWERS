import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_niche_tile.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/discover/home_controller.dart';

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
      AsyncData(value: HomeRows(rows: final value)) => RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
          child: ListView.builder(
            // The first row's heading sits directly under the status bar
            // without this - the clock draws straight through it. The list
            // scrolls under the status bar by design, so the inset belongs on
            // the content rather than on a SafeArea wrapper, which would
            // clip the scroll instead of padding it.
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + RSpace.s8,
              bottom: RSpace.s32,
            ),
            itemCount: value.length,
            itemBuilder: (context, index) => _Row(
              row: value[index],
              onOpenPro: onOpenPro,
              onOpenNiche: onOpenNiche,
            ),
          ),
        ),
      AsyncError() => RErrorState(
          message: 'Could not load photographers.',
          onRetry: () => ref.invalidate(homeControllerProvider),
        ),
      _ => const _LoadingRows(),
    };
  }
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
          padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s24, RSpace.s16, RSpace.s8),
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
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: RSpace.s16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: RSpace.s12),
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
        width: 148,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 148,
              width: 148,
              child: RNetworkPhoto(url: card.coverUrl, semanticLabel: card.displayName),
            ),
            const SizedBox(height: RSpace.s8),
            Text(
              card.displayName ?? 'Photographer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            // Price is the second thing anyone wants and the first thing that
            // must not be invented: a null price renders as nothing rather
            // than as a zero, which would read as free.
            if (card.minPrice != null)
              Text(
                // min_package_price is now the real starting total -
                // the cheapest complete booking, not a per-photo rate.
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
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        for (var row = 0; row < 3; row++) ...[
          const RSkeleton(width: 180, height: 20),
          const SizedBox(height: RSpace.s12),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: RSpace.s12),
              itemBuilder: (context, index) => const RSkeleton(width: 148, height: 148),
            ),
          ),
          const SizedBox(height: RSpace.s24),
        ],
      ],
    );
  }
}
