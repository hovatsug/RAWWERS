import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/tokens.dart';
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

    return asyncData.when(
      loading: () => const RSkeleton(height: 120),
      error: (error, _) => Text('Discover unavailable: $error'),
      data: (data) {
        if (data.items.isEmpty) {
          return const Text('No pros yet.');
        }
        return ListView.separated(
          itemBuilder: (_, index) {
            final item = data.items[index];
            return DiscoverCardTile(item: item, onTap: () => context.go('/pros/${item.proUserId}'));
          },
          separatorBuilder: (_, __) => const SizedBox(height: RTokens.spacingX3),
          itemCount: data.items.length,
        );
      },
    );
  }
}
