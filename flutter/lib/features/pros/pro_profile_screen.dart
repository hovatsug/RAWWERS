import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import 'providers.dart';

class ProProfileScreen extends ConsumerWidget {
  const ProProfileScreen({super.key, required this.proId});

  final String proId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(proProfileProvider(proId));

    return asyncData.when(
      loading: () => const RSkeleton(height: 180),
      error: (error, _) => Text('Profile unavailable: $error'),
      data: (profile) {
        return ListView(
          children: [
            RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.displayName ?? 'Pro ${profile.proUserId.substring(0, 8)}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: RTokens.spacingX1),
                  Text(profile.headline ?? 'Public profile and portfolio.'),
                  const SizedBox(height: RTokens.spacingX2),
                  Text('${profile.city ?? 'Unknown city'}, ${profile.country ?? 'Unknown country'}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: RTokens.spacingX3),
            RCard(
              child: Text(profile.bio ?? 'Bio not available in this profile yet.'),
            ),
          ],
        );
      },
    );
  }
}
