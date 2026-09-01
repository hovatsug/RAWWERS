import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/client.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(apiDioProvider));
});

final notificationsProvider = FutureProvider<List<NotificationItemModel>>((ref) {
  return ref.read(notificationsRepositoryProvider).list();
});
