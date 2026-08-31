import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../../../design/widgets/r_badge.dart';
import '../../../design/widgets/r_glass_card.dart';
import '../../../data/models/discover_models.dart';

class DiscoverCardTile extends StatelessWidget {
  const DiscoverCardTile({super.key, required this.item, this.onTap});

  final DiscoverCardModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = item.displayName ?? 'Pro ${item.proUserId.substring(0, 8)}';
    final initial = name[0].toUpperCase();

    final body = RGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + name + price badge
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [RTokens.violet, RTokens.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(RTokens.radiusMd),
                  boxShadow: RTokens.glowShadow(RTokens.glowVioletSm),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: RTokens.textBase),
                  ),
                ),
              ),
              const SizedBox(width: RTokens.spacingX3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${item.city ?? 'Unknown city'}, ${item.country ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (item.minPrice != null)
                RBadge(
                  label: '${item.currency ?? 'EUR'} ${item.minPrice!.toStringAsFixed(0)}+',
                  variant: RBadgeVariant.violet,
                ),
            ],
          ),

          if (item.headline != null && item.headline!.isNotEmpty) ...[
            const SizedBox(height: RTokens.spacingX2),
            Text(item.headline!, style: Theme.of(context).textTheme.bodyMedium),
          ],

          if (item.topNiches.isNotEmpty) ...[
            const SizedBox(height: RTokens.spacingX2),
            Wrap(
              spacing: RTokens.spacingX1,
              runSpacing: RTokens.spacingX1,
              children: item.topNiches.take(5).map((tag) => RBadge(label: tag)).toList(),
            ),
          ],

          if (item.avgRating != null) ...[
            const SizedBox(height: RTokens.spacingX2),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: RTokens.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  item.avgRating!.toStringAsFixed(1),
                  style: const TextStyle(fontSize: RTokens.textXs, fontWeight: FontWeight.w600, color: RTokens.textOnDark),
                ),
                const SizedBox(width: 4),
                Text(
                  '· ${item.reviewCount ?? 0} reviews',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return body;
    return GestureDetector(onTap: onTap, child: body);
  }
}
