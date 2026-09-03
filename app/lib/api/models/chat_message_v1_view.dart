/// ChatMessageV1View
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "thread_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Thread Id"
///         },
///         "sender_type": {
///             "$ref": "#/components/schemas/ChatSenderType"
///         },
///         "sender_user_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Sender User Id"
///         },
///         "content": {
///             "type": "string",
///             "title": "Content"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "thread_id",
///         "sender_type",
///         "content",
///         "created_at"
///     ],
///     "title": "ChatMessageV1View"
/// }
library chat_message_v1_view;

import 'exports.dart';
part 'chat_message_v1_view.freezed.dart';
part 'chat_message_v1_view.g.dart'; // ChatMessageV1View

@freezed
abstract class ChatMessageV1View with _$ChatMessageV1View {
  const ChatMessageV1View._();

  @jsonSerializable
  const factory ChatMessageV1View({
    /// id
    @JsonKey(name: ChatMessageV1View.idKey_) required String id,

    /// threadId
    @JsonKey(name: ChatMessageV1View.threadIdKey_) required String threadId,

    /// senderType
    @JsonKey(name: ChatMessageV1View.senderTypeKey_)
    required ChatSenderType senderType,

    /// senderUserId
    @JsonKey(name: ChatMessageV1View.senderUserIdKey_) String? senderUserId,

    /// content
    @JsonKey(name: ChatMessageV1View.contentKey_) required String content,

    /// metadata
    @JsonKey(name: ChatMessageV1View.metadataKey_)
    Map<String, dynamic>? metadata,

    /// createdAt
    @JsonKey(name: ChatMessageV1View.createdAtKey_) required DateTime createdAt,
  }) = _ChatMessageV1View;

  factory ChatMessageV1View.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageV1ViewFromJson(json);

  static const String idKey_ = r'id';

  static const String threadIdKey_ = r'thread_id';

  static const String senderTypeKey_ = r'sender_type';

  static const String senderUserIdKey_ = r'sender_user_id';

  static const String contentKey_ = r'content';

  static const String metadataKey_ = r'metadata';

  static const String createdAtKey_ = r'created_at';
}
