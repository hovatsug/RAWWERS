import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_glow_orbs.dart';
import '../../design/widgets/r_skeleton.dart';
import '../flags/providers.dart';
import 'providers.dart';
import 'widgets/discover_card_tile.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(flagEnabledProvider('client_discovery_enabled'));
    if (!enabled) {
      return const Center(child: Text('Discovery disabled by feature flag'));
    }

    final asyncData = ref.watch(discoverProvider);

    return Stack(
      children: [
        const RGlowOrbs(variant: RGlowOrbsVariant.discovery),
        asyncData.when(
          loading: () => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RSkeleton(height: 32, width: 160),
              SizedBox(height: RTokens.spacingX4),
              RSkeleton(height: 110),
              SizedBox(height: RTokens.spacingX3),
              RSkeleton(height: 110),
              SizedBox(height: RTokens.spacingX3),
              RSkeleton(height: 110),
            ],
          ),
          error: (error, _) => Center(
            child: Text('Discover unavailable', style: Theme.of(context).textTheme.bodyMedium),
          ),
          data: (data) {
            if (data.items.isEmpty) {
              return Center(
                child: Text('No pros yet.', style: Theme.of(context).textTheme.bodyMedium),
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discover', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Find your perfect creative professional',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: RTokens.spacingX4),
                    ],
                  ),
                ),
                SliverList.separated(
                  itemCount: data.items.length,
                  itemBuilder: (_, index) {
                    final item = data.items[index];
                    return DiscoverCardTile(
                      item: item,
                      onTap: () => context.go('/pros/${item.proUserId}'),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: RTokens.spacingX3),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ],
    );
  }
}
