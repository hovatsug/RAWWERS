/// ChatThreadSummary
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "client_user_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Client User Id"
///         },
///         "session_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Session Id"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ChatThreadStatus"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         },
///         "pro_display_name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Pro Display Name"
///         },
///         "client_display_name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Client Display Name"
///         },
///         "unread_count": {
///             "type": "integer",
///             "default": 0,
///             "title": "Unread Count"
///         },
///         "last_message_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Last Message At"
///         },
///         "last_message_preview": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Last Message Preview"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "pro_user_id",
///         "status",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "ChatThreadSummary"
/// }
library chat_thread_summary;

import 'exports.dart';
part 'chat_thread_summary.freezed.dart';
part 'chat_thread_summary.g.dart'; // ChatThreadSummary

@freezed
abstract class ChatThreadSummary with _$ChatThreadSummary {
  const ChatThreadSummary._();

  @jsonSerializable
  const factory ChatThreadSummary({
    /// id
    @JsonKey(name: ChatThreadSummary.idKey_) required String id,

    /// proUserId
    @JsonKey(name: ChatThreadSummary.proUserIdKey_) required String proUserId,

    /// clientUserId
    @JsonKey(name: ChatThreadSummary.clientUserIdKey_) String? clientUserId,

    /// sessionId
    @JsonKey(name: ChatThreadSummary.sessionIdKey_) String? sessionId,

    /// status
    @JsonKey(name: ChatThreadSummary.statusKey_)
    required ChatThreadStatus status,

    /// createdAt
    @JsonKey(name: ChatThreadSummary.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: ChatThreadSummary.updatedAtKey_) required DateTime updatedAt,

    /// proDisplayName
    @JsonKey(name: ChatThreadSummary.proDisplayNameKey_) String? proDisplayName,

    /// clientDisplayName
    @JsonKey(name: ChatThreadSummary.clientDisplayNameKey_)
    String? clientDisplayName,

    /// unreadCount
    @Default(0)
    @JsonKey(name: ChatThreadSummary.unreadCountKey_)
    int unreadCount,

    /// lastMessageAt
    @JsonKey(name: ChatThreadSummary.lastMessageAtKey_) DateTime? lastMessageAt,

    /// lastMessagePreview
    @JsonKey(name: ChatThreadSummary.lastMessagePreviewKey_)
    String? lastMessagePreview,
  }) = _ChatThreadSummary;

  factory ChatThreadSummary.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadSummaryFromJson(json);

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String sessionIdKey_ = r'session_id';

  static const String statusKey_ = r'status';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';

  static const String proDisplayNameKey_ = r'pro_display_name';

  static const String clientDisplayNameKey_ = r'client_display_name';

  static const String unreadCountKey_ = r'unread_count';

  static const String lastMessageAtKey_ = r'last_message_at';

  static const String lastMessagePreviewKey_ = r'last_message_preview';
}
