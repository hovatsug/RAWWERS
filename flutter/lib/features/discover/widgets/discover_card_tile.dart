import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../../../design/widgets/r_badge.dart';
import '../../../design/widgets/r_card.dart';
import '../../../data/models/discover_models.dart';

class DiscoverCardTile extends StatelessWidget {
  const DiscoverCardTile({super.key, required this.item, this.onTap});

  final DiscoverCardModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.displayName ?? 'Pro ${item.proUserId.substring(0, 8)}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: RTokens.spacingX1),
          if (item.headline != null && item.headline!.isNotEmpty)
            Text(item.headline!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: RTokens.spacingX1),
          Text('${item.city ?? 'Unknown city'}, ${item.country ?? 'Unknown'}'),
          const SizedBox(height: RTokens.spacingX2),
          if (item.minPrice != null) RBadge(label: '${item.currency ?? 'EUR'} ${item.minPrice!.toStringAsFixed(0)}+'),
          const SizedBox(height: RTokens.spacingX1),
          Text('${item.avgRating?.toStringAsFixed(1) ?? '-'} rating • ${item.reviewCount ?? 0} reviews', style: Theme.of(context).textTheme.bodySmall),
          if (item.topNiches.isNotEmpty) ...[
            const SizedBox(height: RTokens.spacingX1),
            Wrap(
              spacing: RTokens.spacingX1,
              runSpacing: RTokens.spacingX1,
              children: item.topNiches.take(5).map((tag) => RBadge(label: tag)).toList(),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(onTap: onTap, child: body);
  }
}
