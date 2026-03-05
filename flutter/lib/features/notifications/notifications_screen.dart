import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import 'providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(notificationsProvider);

    return asyncData.when(
      loading: () => const RSkeleton(height: 120),
      error: (error, _) => Text('Notifications unavailable: $error'),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No notifications'));
        }
        return ListView.separated(
          itemBuilder: (_, index) {
            final item = items[index];
            return RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: RTokens.spacingX1),
                  Text(item.body),
                  const SizedBox(height: RTokens.spacingX2),
                  Row(
                    children: [
                      Text(item.createdAt, style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      if (!item.isRead)
                        RButton(
                          label: 'Mark read',
                          variant: RButtonVariant.secondary,
                          onPressed: () async {
                            await ref.read(notificationsRepositoryProvider).markRead(item.id);
                            ref.invalidate(notificationsProvider);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: RTokens.spacingX3),
          itemCount: items.length,
        );
      },
    );
  }
}
