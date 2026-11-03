import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/notification_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'notifications_controller.g.dart';

/// The signed-in person's notifications, newest first: the most recent 50,
/// read and unread. Both apps read the same feed (GET /v1/me/notifications);
/// each has its own screen and decides where a notification leads.
@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  Future<List<NotificationView>> build() async {
    final result = await apiCall(
      () => ref.read(notificationsClientProvider).getMyNotificationsV1MeNotificationsGet(
            limit: 50,
            cursor: null,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return switch (result) {
      Ok(:final value) => value.items,
      Err(:final failure) => throw failure,
    };
  }

  /// Marks one read, at once on screen; the bell recounts.
  Future<void> markRead(NotificationView notification) async {
    if (notification.readAt != null) return;
    final now = DateTime.now().toUtc();
    _replace((n) => n.id == notification.id ? n.copyWith(readAt: now) : n);
    await apiCall(
      () => ref.read(notificationsClientProvider).readNotificationV1MeNotificationsNotificationIdReadPost(
            notificationId: notification.id,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    ref.invalidate(unreadCountProvider);
  }

  /// Marks every one read. Null when done, otherwise what to say.
  Future<String?> markAllRead() async {
    final result = await apiCall(
      () => ref.read(notificationsClientProvider).readAllNotificationsV1MeNotificationsReadAllPost(
            typePrefix: null,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    switch (result) {
      case Ok():
        final now = DateTime.now().toUtc();
        _replace((n) => n.readAt == null ? n.copyWith(readAt: now) : n);
        ref.invalidate(unreadCountProvider);
        return null;
      case Err():
        return 'Could not mark them read. Try again.';
    }
  }

  void _replace(NotificationView Function(NotificationView) change) {
    final current = state.valueOrNull;
    if (current != null) state = AsyncData([for (final n in current) change(n)]);
  }
}

/// How many are unread: every kind, or only those whose type starts with
/// [typePrefix] ("shelf.order_" for the dot on My orders). Zero when the
/// count cannot be had: a badge is not worth an error.
@riverpod
Future<int> unreadCount(Ref ref, {String? typePrefix}) async {
  final result = await apiCall(
    () => ref.read(notificationsClientProvider).getMyUnreadCountV1MeNotificationsUnreadCountGet(
          typePrefix: typePrefix,
          authorization: null,
          xMinusUserMinusId: null,
        ),
  );
  return switch (result) {
    Ok(:final value) => value.count,
    Err() => 0,
  };
}

/// Marks read every notification whose type starts with its argument, and
/// recounts: opening My orders reads its order updates ("shelf.order_").
typedef NotificationKindReader = Future<void> Function(String typePrefix);

/// Kept alive: it is called and then awaited by a screen that may be gone
/// by the time the call returns.
@Riverpod(keepAlive: true)
NotificationKindReader notificationKindReader(Ref ref) => (typePrefix) async {
      await apiCall(
        () => ref.read(notificationsClientProvider).readAllNotificationsV1MeNotificationsReadAllPost(
              typePrefix: typePrefix,
              authorization: null,
              xMinusUserMinusId: null,
            ),
      );
      ref.invalidate(unreadCountProvider);
      ref.invalidate(notificationsControllerProvider);
    };
