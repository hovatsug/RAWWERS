/// ChatMessageView
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
///     "title": "ChatMessageView"
/// }
library chat_message_view;

import 'exports.dart';
part 'chat_message_view.freezed.dart';
part 'chat_message_view.g.dart'; // ChatMessageView

@freezed
abstract class ChatMessageView with _$ChatMessageView {
  const ChatMessageView._();

  @jsonSerializable
  const factory ChatMessageView({
    /// id
    @JsonKey(name: ChatMessageView.idKey_) required String id,

    /// threadId
    @JsonKey(name: ChatMessageView.threadIdKey_) required String threadId,

    /// senderType
    @JsonKey(name: ChatMessageView.senderTypeKey_)
    required ChatSenderType senderType,

    /// senderUserId
    @JsonKey(name: ChatMessageView.senderUserIdKey_) String? senderUserId,

    /// content
    @JsonKey(name: ChatMessageView.contentKey_) required String content,

    /// metadata
    @JsonKey(name: ChatMessageView.metadataKey_) Map<String, dynamic>? metadata,

    /// createdAt
    @JsonKey(name: ChatMessageView.createdAtKey_) required DateTime createdAt,
  }) = _ChatMessageView;

  factory ChatMessageView.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageViewFromJson(json);

  static const String idKey_ = r'id';

  static const String threadIdKey_ = r'thread_id';

  static const String senderTypeKey_ = r'sender_type';

  static const String senderUserIdKey_ = r'sender_user_id';

  static const String contentKey_ = r'content';

  static const String metadataKey_ = r'metadata';

  static const String createdAtKey_ = r'created_at';
}
