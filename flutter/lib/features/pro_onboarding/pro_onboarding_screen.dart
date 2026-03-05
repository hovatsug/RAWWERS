import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_badge.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import '../flags/providers.dart';
import 'providers.dart';

class ProOnboardingScreen extends ConsumerWidget {
  const ProOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(flagEnabledProvider('pro_onboarding_enabled'));
    if (!enabled) {
      return const Center(child: Text('Onboarding disabled by feature flag'));
    }

    final asyncData = ref.watch(proOnboardingChecksProvider);

    return asyncData.when(
      loading: () => const RSkeleton(height: 120),
      error: (error, _) => Text('Onboarding unavailable: $error'),
      data: (data) {
        return ListView(
          children: [
            RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pro Onboarding', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: RTokens.spacingX2),
                  RBadge(label: 'Status: ${data.status}'),
                ],
              ),
            ),
            const SizedBox(height: RTokens.spacingX3),
            RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checklist', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: RTokens.spacingX2),
                  ...data.checks.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: RTokens.spacingX1),
                      child: Row(
                        children: [
                          Icon(entry.value ? Icons.check_circle_outline : Icons.radio_button_unchecked, size: 18),
                          const SizedBox(width: RTokens.spacingX2),
                          Expanded(child: Text(entry.key)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
