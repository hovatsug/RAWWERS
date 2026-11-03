import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/notification_view.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/shared/notifications/notifications_controller.dart';

/// Where a notification leads in this app, or null when it has nowhere to
/// go here. Each app has its own: a route in one is not a route in the other.
typedef NotificationRoute = String? Function(NotificationView notification);

/// The list behind each app's notifications screen: newest first, unread
/// marked, "Mark all read" above. Tapping one marks it read and opens where
/// it leads, when [routeFor] knows a place.
class NotificationsList extends ConsumerWidget {
  const NotificationsList({required this.routeFor, super.key});

  final NotificationRoute routeFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsControllerProvider);
    final hasUnread = notifications.valueOrNull?.any((n) => n.readAt == null) ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final problem = await ref.read(notificationsControllerProvider.notifier).markAllRead();
                if (problem != null) messenger.showSnackBar(SnackBar(content: Text(problem)));
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (notifications) {
          AsyncData(:final value) when value.isEmpty => const REmptyState(
              title: 'Nothing yet',
              body: 'Updates about your bookings and orders show here.',
              icon: Icons.notifications_none,
            ),
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.refresh(notificationsControllerProvider.future),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: value.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _Row(notification: value[i], route: routeFor(value[i])),
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Notifications could not be loaded.',
              onRetry: () => ref.invalidate(notificationsControllerProvider),
            ),
          _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(width: RSize.lineMedium)),
        },
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.notification, required this.route});

  final NotificationView notification;
  final String? route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unread = notification.readAt == null;
    return ListTile(
      leading: Icon(unread ? Icons.circle : Icons.circle_outlined, size: RIcon.inline, color: unread ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
      title: Text(notification.title, style: unread ? theme.textTheme.titleSmall : theme.textTheme.bodyLarge),
      subtitle: Text(notification.body),
      trailing: Text(RDates.of(context).relative(notification.createdAt), style: theme.textTheme.bodySmall),
      onTap: () {
        ref.read(notificationsControllerProvider.notifier).markRead(notification);
        if (route != null) context.push(route!);
      },
    );
  }
}
