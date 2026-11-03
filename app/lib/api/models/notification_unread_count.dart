/// NotificationUnreadCount
/// {
///     "properties": {
///         "count": {
///             "type": "integer",
///             "title": "Count"
///         }
///     },
///     "type": "object",
///     "required": [
///         "count"
///     ],
///     "title": "NotificationUnreadCount"
/// }
library notification_unread_count;

import 'exports.dart';
part 'notification_unread_count.freezed.dart';
part 'notification_unread_count.g.dart'; // NotificationUnreadCount

@freezed
abstract class NotificationUnreadCount with _$NotificationUnreadCount {
  const NotificationUnreadCount._();

  @jsonSerializable
  const factory NotificationUnreadCount({
    /// count
    @JsonKey(name: NotificationUnreadCount.countKey_) required int count,
  }) = _NotificationUnreadCount;

  factory NotificationUnreadCount.fromJson(Map<String, dynamic> json) =>
      _$NotificationUnreadCountFromJson(json);

  static const String countKey_ = r'count';
}
