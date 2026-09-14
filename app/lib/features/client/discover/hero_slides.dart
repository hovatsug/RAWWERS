import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/client_home_row.dart';

/// One hero slide: a niche, and the photographer who currently leads it.
class HeroSlide {
  const HeroSlide({required this.nicheSlug, required this.title, required this.card});

  /// The niche this slide is about. Kept so the tap target can become the
  /// niche's own page once that exists, without changing what a slide is.
  final String nicheSlug;

  /// The row's own title, server-composed - "Weddings in Lisbon". Not rebuilt
  /// here: what a row is called is a decision the server already made, and
  /// two places composing the same label is how they drift.
  final String title;

  final ClientDiscoverCard card;
}

const _nichePrefix = 'niche:';

/// The slides for a hero carousel, derived from the rows the home screen was
/// already given.
///
/// No second request and no second ranking. The niche rows are already
/// ordered by the same `ranking_score` everything else uses, so the leader of
/// each niche is simply its first card.
///
/// **Deduplicated by photographer.** In Lisbon one photographer currently
/// tops weddings, portraits and family, so three of four slides would show
/// the same person under three different labels. That does not read as an
/// honest ranking, it reads as broken - and a carousel exists to show the
/// breadth of a marketplace. Each niche takes its top photographer who has
/// not already appeared.
///
/// A niche whose photographers have all been used contributes no slide.
/// Fewer slides is the honest outcome in a thin city, the same rule the rows
/// already follow: absent rather than padded.
///
/// A card with no cover is skipped too. A hero is the image; one without a
/// photograph is a coloured rectangle with a name on it.
List<HeroSlide> heroSlidesFrom(List<ClientHomeRow> rows) {
  final slides = <HeroSlide>[];
  final used = <String>{};

  for (final row in rows) {
    if (!row.key.startsWith(_nichePrefix)) continue;

    for (final card in row.items ?? const <ClientDiscoverCard>[]) {
      if (used.contains(card.proUserId)) continue;
      final cover = card.coverUrl;
      if (cover == null || cover.isEmpty) continue;

      used.add(card.proUserId);
      slides.add(
        HeroSlide(
          nicheSlug: row.key.substring(_nichePrefix.length),
          title: row.title,
          card: card,
        ),
      );
      break;
    }
  }
  return slides;
}
