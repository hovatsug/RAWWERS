import 'package:dio/dio.dart';

import '../models/notification_item.dart';

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  Future<List<NotificationItemModel>> list({bool unreadOnly = false}) async {
    final response = await _dio.get<Map<String, dynamic>>('/me/notifications', queryParameters: {'unread_only': unreadOnly, 'limit': 50});
    final rows = (response.data?['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>();
    return rows.map(NotificationItemModel.fromJson).toList();
  }

  Future<void> markRead(String id) async {
    await _dio.post('/me/notifications/$id/read');
  }
}
