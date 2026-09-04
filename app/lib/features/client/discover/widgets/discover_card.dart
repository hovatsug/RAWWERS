import 'package:flutter/material.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/tokens.dart';

/// One photographer in the Discover list.
///
/// Deliberately renders no cover photo. `ClientDiscoverCard` carries
/// `cover_media_asset_id` but no URL, so showing an image would mean one
/// `GET /v1/media/{id}` per card - twenty extra round trips on a twenty-card
/// screen, on the first thing a client ever sees. Until the card carries a
/// URL (or a batch resolve exists), this leads with the things that are
/// actually in the payload and are what someone picks a photographer on:
/// price range, rating, and what they shoot.
class DiscoverCard extends StatelessWidget {
  const DiscoverCard({required this.card, required this.onTap, super.key});

  final ClientDiscoverCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    card.displayName ?? 'Photographer',
                    style: theme.textTheme.titleMedium,
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
              Text(card.headline!, style: theme.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: RSpace.s12),
            Text(_priceLine(card), style: theme.textTheme.titleSmall?.copyWith(fontFeatures: RType.tabularFigures)),
            if ((card.topNiches ?? const []).isNotEmpty) ...[
              const SizedBox(height: RSpace.s8),
              Text(
                _nicheLine(card),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
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
