import 'package:flutter/material.dart';
import 'package:rawwers/api/models/notification_view.dart';
import 'package:rawwers/features/shared/notifications/notifications_list.dart';

/// Where a notification leads in the pro app, or null when it has nowhere to
/// go here. Its link first (the app paths the server sends), then its type.
String? proNotificationRoute(
  NotificationView notification, {
  required String shelfPath,
  required String shelfOrdersPath,
  required String requestsPath,
  required String walletPath,
}) {
  final url = notification.action?.url ?? '';
  if (url == shelfOrdersPath || notification.type.startsWith('shelf.order_')) return shelfOrdersPath;
  if (url == shelfPath || notification.type.startsWith('shelf.raww_')) return shelfPath;
  if (notification.type.startsWith('booking.request_')) return requestsPath;
  if (notification.type.startsWith('payout.')) return walletPath;
  return null;
}

/// The photographer's notifications.
class ProNotificationsScreen extends StatelessWidget {
  const ProNotificationsScreen({
    required this.shelfPath,
    required this.shelfOrdersPath,
    required this.requestsPath,
    required this.walletPath,
    super.key,
  });

  final String shelfPath;
  final String shelfOrdersPath;
  final String requestsPath;
  final String walletPath;

  @override
  Widget build(BuildContext context) => NotificationsList(
        routeFor: (n) => proNotificationRoute(
          n,
          shelfPath: shelfPath,
          shelfOrdersPath: shelfOrdersPath,
          requestsPath: requestsPath,
          walletPath: walletPath,
        ),
      );
}
