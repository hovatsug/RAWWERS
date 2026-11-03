import 'package:rawwers/api/models/notification_action.dart';
import 'package:rawwers/api/models/notification_severity.dart';
import 'package:rawwers/api/models/notification_view.dart';

NotificationView notification({
  String id = 'n1',
  String type = 'shelf.order_shipped',
  String title = 'On its way',
  String body = 'Card has shipped.',
  String? url,
  bool read = false,
  DateTime? createdAt,
}) =>
    NotificationView(
      id: id,
      topic: 'general',
      type: type,
      title: title,
      body: body,
      action: url == null ? null : NotificationAction(label: 'Open', url: url),
      severity: NotificationSeverity.info,
      readAt: read ? DateTime.utc(2026, 11, 3, 12) : null,
      createdAt: createdAt ?? DateTime.now().subtract(const Duration(hours: 2)),
    );
