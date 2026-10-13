import 'package:flutter/material.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_package_price.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/design/components/r_online_dot.dart';

/// One photographer in the Discover list.
///
/// Lives in shared, not under client, because the pro app renders the same
/// widget for the listing preview. A photographer being shown a copy of
/// their card would eventually be shown a card that no longer matches what
/// a client sees, and the whole point of the preview is that it does.
///
/// Photo-led on purpose: this is the first screen a client sees, and nobody
/// picks a photographer from a price range. The cover is a 3:2 frame - the
/// native aspect of most cameras - and the text sits beneath it rather than
/// over it, so a caption is never fighting the image for legibility.
class DiscoverCard extends StatelessWidget {
  const DiscoverCard({required this.card, required this.onTap, super.key});

  final ClientDiscoverCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = card.displayName ?? 'Photographer';

    return Semantics(
      button: true,
      label: name,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(RRadius.surface),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RRadius.surface),
            child: Column(
              // Sized to its content: the card is laid out inside a list, and
              // a max-height column would stretch the photo to whatever space
              // it happened to be given.
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: RNetworkPhoto(url: card.coverUrl, semanticLabel: '$name cover photo'),
                ),
                Padding(
                  padding: const EdgeInsets.all(RSpace.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(child: Text(name, style: theme.textTheme.titleMedium)),
                                if (card.online) ...[const SizedBox(width: RSpace.s8), const ROnlineDot()],
                              ],
                            ),
                          ),
                          if (card.reviewCount > 0) ...[
                            const SizedBox(width: RSpace.s8),
                            _Rating(rating: card.avgRating, count: card.reviewCount),
                          ],
                        ],
                      ),
                      if (card.headline != null) ...[
                        const SizedBox(height: RSpace.s4),
                        Text(
                          card.headline!,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: RSpace.s12),
                      // The rate leads, as it does on the profile card. The
                      // total alone is a large bare number with no unit, and
                      // this card is what a photographer previews their own
                      // listing with - it must say the same thing a client
                      // will read.
                      if (card.minEntryRate != null && card.minPrice != null)
                        RPackagePrice(
                          entryRate: card.minEntryRate!,
                          minimumPhotos: card.minEntryPhotos ?? 0,
                          startingTotal: card.minPrice!,
                          maxTotal: card.maxPrice,
                          currency: card.currency,
                          density: RPackagePriceDensity.card,
                        )
                      else
                        Text(
                          _priceLine(card),
                          style: theme.textTheme.titleSmall?.copyWith(fontFeatures: RType.tabularFigures),
                        ),
                      if ((card.topNiches ?? const []).isNotEmpty) ...[
                        const SizedBox(height: RSpace.s8),
                        Text(
                          _nicheLine(card),
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Shown exactly as the server words it; null means say
                      // nothing (no history yet, or a slow one).
                      if (card.responseLabel != null) ...[
                        const SizedBox(height: RSpace.s4),
                        Text(
                          card.responseLabel!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating, required this.count});

  final String rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 16),
        const SizedBox(width: RSpace.s4),
        Text(rating, style: theme.textTheme.bodySmall?.copyWith(fontFeatures: RType.tabularFigures)),
        Text(' ($count)', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Money stays a decimal string end to end - never parsed to a double just
/// to render it.
///
/// Only reached when the index row has no entry rate yet, in which case the
/// total alone is what this card has always shown. With a rate present the
/// card renders RPackagePrice instead, so the rate leads here exactly as it
/// does on the profile.
String _priceLine(ClientDiscoverCard card) {
  final min = card.minPrice;
  final max = card.maxPrice;
  if (min == null && max == null) return 'Price on request';
  if (min != null && max != null && min != max) return 'From €$min to €$max';
  return 'From €${min ?? max}';
}

/// `top_niches` is an untyped list of maps in the schema, so this reads keys
/// defensively rather than assuming a shape the API doesn't guarantee.
String _nicheLine(ClientDiscoverCard card) {
  final slugs = <String>[];
  for (final niche in card.topNiches ?? const <Map<String, dynamic>>[]) {
    final slug = niche['slug'];
    if (slug is String && slug.isNotEmpty) slugs.add(_humanise(slug));
    if (slugs.length == 3) break;
  }
  return slugs.join(' · ');
}

String _humanise(String slug) {
  return slug
      .split('-')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
