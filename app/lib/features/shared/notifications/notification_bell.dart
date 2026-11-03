import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/features/shared/notifications/notifications_controller.dart';

/// The bell, with how many notifications are unread. Each app puts it where
/// it belongs and says where it opens.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({required this.onOpen, super.key});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider()).valueOrNull ?? 0;
    return IconButton(
      tooltip: count == 0 ? 'Notifications' : 'Notifications, $count unread',
      onPressed: onOpen,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: Icon(count > 0 ? Icons.notifications : Icons.notifications_none),
      ),
    );
  }
}
