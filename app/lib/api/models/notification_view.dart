/// NotificationView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "topic": {
///             "type": "string",
///             "title": "Topic"
///         },
///         "type": {
///             "type": "string",
///             "title": "Type"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "body": {
///             "type": "string",
///             "title": "Body"
///         },
///         "action": {
///             "$ref": "#/components/schemas/NotificationAction"
///         },
///         "severity": {
///             "$ref": "#/components/schemas/NotificationSeverity"
///         },
///         "read_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Read At"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "topic",
///         "type",
///         "title",
///         "body",
///         "severity",
///         "read_at",
///         "created_at"
///     ],
///     "title": "NotificationView"
/// }
library notification_view;

import 'exports.dart';
part 'notification_view.freezed.dart';
part 'notification_view.g.dart'; // NotificationView

@freezed
abstract class NotificationView with _$NotificationView {
  const NotificationView._();

  @jsonSerializable
  const factory NotificationView({
    /// id
    @JsonKey(name: NotificationView.idKey_) required String id,

    /// topic
    @JsonKey(name: NotificationView.topicKey_) required String topic,

    /// type
    @JsonKey(name: NotificationView.typeKey_) required String type,

    /// title
    @JsonKey(name: NotificationView.titleKey_) required String title,

    /// body
    @JsonKey(name: NotificationView.bodyKey_) required String body,

    /// action
    @JsonKey(name: NotificationView.actionKey_) NotificationAction? action,

    /// severity
    @JsonKey(name: NotificationView.severityKey_)
    required NotificationSeverity severity,

    /// readAt
    @JsonKey(name: NotificationView.readAtKey_) required DateTime? readAt,

    /// createdAt
    @JsonKey(name: NotificationView.createdAtKey_) required DateTime createdAt,

    /// metadata
    @JsonKey(name: NotificationView.metadataKey_)
    Map<String, dynamic>? metadata,
  }) = _NotificationView;

  factory NotificationView.fromJson(Map<String, dynamic> json) =>
      _$NotificationViewFromJson(json);

  static const String idKey_ = r'id';

  static const String topicKey_ = r'topic';

  static const String typeKey_ = r'type';

  static const String titleKey_ = r'title';

  static const String bodyKey_ = r'body';

  static const String actionKey_ = r'action';

  static const String severityKey_ = r'severity';

  static const String readAtKey_ = r'read_at';

  static const String createdAtKey_ = r'created_at';

  static const String metadataKey_ = r'metadata';
}
