/// NotificationTopicPreferenceBulkUpdate
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/NotificationTopicPreferenceUpsert"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items"
///     ],
///     "title": "NotificationTopicPreferenceBulkUpdate"
/// }
library notification_topic_preference_bulk_update;

import 'exports.dart';
part 'notification_topic_preference_bulk_update.freezed.dart';
part 'notification_topic_preference_bulk_update.g.dart'; // NotificationTopicPreferenceBulkUpdate

@freezed
abstract class NotificationTopicPreferenceBulkUpdate
    with _$NotificationTopicPreferenceBulkUpdate {
  const NotificationTopicPreferenceBulkUpdate._();

  @jsonSerializable
  const factory NotificationTopicPreferenceBulkUpdate({
    /// items
    @JsonKey(name: NotificationTopicPreferenceBulkUpdate.itemsKey_)
    required List<NotificationTopicPreferenceUpsert> items,
  }) = _NotificationTopicPreferenceBulkUpdate;

  factory NotificationTopicPreferenceBulkUpdate.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationTopicPreferenceBulkUpdateFromJson(json);

  static const String itemsKey_ = r'items';
}
