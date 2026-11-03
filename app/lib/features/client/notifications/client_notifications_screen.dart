import 'package:flutter/material.dart';
import 'package:rawwers/api/models/notification_view.dart';
import 'package:rawwers/features/shared/notifications/notifications_list.dart';

/// Where a notification leads in the client app, or null when it has
/// nowhere to go here. Its link first (the app paths the server sends),
/// then its type.
String? clientNotificationRoute(
  NotificationView notification, {
  required String marketingPermissionsPath,
  required String bookingsPath,
}) {
  final url = notification.action?.url ?? '';
  if (url == marketingPermissionsPath || notification.type.startsWith('marketing_consent.')) return marketingPermissionsPath;
  // The list rather than one booking: the ids the server links to are not
  // all the ones the app's booking screen opens by.
  if (notification.type.startsWith('booking.') || notification.type.startsWith('payment.')) return bookingsPath;
  return null;
}

/// The client's notifications.
class ClientNotificationsScreen extends StatelessWidget {
  const ClientNotificationsScreen({
    required this.marketingPermissionsPath,
    required this.bookingsPath,
    super.key,
  });

  final String marketingPermissionsPath;
  final String bookingsPath;

  @override
  Widget build(BuildContext context) => NotificationsList(
        routeFor: (n) => clientNotificationRoute(
          n,
          marketingPermissionsPath: marketingPermissionsPath,
          bookingsPath: bookingsPath,
        ),
      );
}
