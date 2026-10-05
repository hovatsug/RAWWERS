import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/discover/home_controller.dart';
import 'package:rawwers/features/client/discover/widgets/hero_carousel.dart';
import 'package:rawwers/features/client/discover/widgets/photographer_rows.dart';
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
      _ => const PhotographerRowsSkeleton(),
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
              // The niche is what a slide showcases; its photographer is the
              // evidence for it. So a slide opens the niche's page, the same
              // destination as the niche's tile.
              onOpen: (slide) => onOpenNiche?.call(slide.nicheSlug),
            );
          }
          return PhotographerRow(
            row: rows[index - (hasHero ? 1 : 0)],
            onOpenPro: onOpenPro,
            onOpenNiche: onOpenNiche,
          );
        },
      ),
    );
  }
}
