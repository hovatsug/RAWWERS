import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/discover/hero_slides.dart';
import 'package:rawwers/features/client/discover/niche_controller.dart';
import 'package:rawwers/features/client/discover/widgets/hero_carousel.dart';
import 'package:rawwers/features/client/discover/widgets/photographer_rows.dart';

/// One niche's page - where a niche tile, its row heading and its hero slide
/// all lead.
///
/// Built from the home screen's parts rather than beside them: the same rows
/// and cards, the same hero, the same server-composed rows. What makes it this
/// niche's page is the request, not a second screen with its own ideas about
/// who belongs in "New in Weddings".
class NicheScreen extends ConsumerWidget {
  const NicheScreen({required this.nicheSlug, this.onOpenPro, super.key});

  final String nicheSlug;
  final void Function(String proUserId)? onOpenPro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nicheControllerProvider(nicheSlug));

    // The title is the server's name for the niche, once known. Until then,
    // nothing - not the slug, which is an identifier, not a name.
    final title = switch (state) {
      AsyncData(value: NichePage(:final niche)) => niche.name,
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: switch (state) {
        AsyncData(value: NicheNeedsLocation()) => const REmptyState(
            title: 'Where are you looking?',
            body: 'Choose a city and we will show you the photographers working there.',
            icon: Icons.location_on_outlined,
          ),
        AsyncData(value: NicheNotFound()) => const REmptyState(
            title: "This category isn't available",
            body: 'It may have been renamed or removed. Go back to see what is on offer.',
            icon: Icons.category_outlined,
          ),
        AsyncData(value: NichePage(:final niche, :final rows)) when rows.isEmpty => REmptyState(
            title: 'No photographers here yet',
            body: 'Nobody in this city offers ${niche.name} at the moment. Try another city.',
            icon: Icons.photo_camera_outlined,
          ),
        AsyncData(value: NichePage(:final niche, :final rows)) => RefreshIndicator(
            onRefresh: () => ref.read(nicheControllerProvider(nicheSlug).notifier).refresh(),
            child: _Page(
              slides: nicheHeroSlidesFrom(rows, nicheSlug: niche.slug),
              rows: [
                for (final row in rows)
                  PhotographerRow(key: ValueKey('row:${row.key}'), row: row, onOpenPro: onOpenPro),
              ],
              onOpenPro: onOpenPro,
            ),
          ),
        AsyncError() => RErrorState(
            message: 'Could not load photographers.',
            onRetry: () => ref.invalidate(nicheControllerProvider(nicheSlug)),
          ),
        _ => const PhotographerRowsSkeleton(),
      },
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.slides, required this.rows, this.onOpenPro});

  final List<HeroSlide> slides;
  final List<Widget> rows;
  final void Function(String proUserId)? onOpenPro;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: RSpace.s32),
      children: [
        // Every slide here is this niche, so a slide opens the photographer it
        // shows - opening the niche would reload the page you are on.
        HeroCarousel(slides: slides, onOpen: (slide) => onOpenPro?.call(slide.card.proUserId)),
        ...rows,
      ],
    );
  }
}
