/// ChatMessagesAppendResponse
/// {
///     "properties": {
///         "thread_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Thread Id"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ChatThreadStatus"
///         },
///         "appended": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ChatMessageView"
///             },
///             "title": "Appended"
///         }
///     },
///     "type": "object",
///     "required": [
///         "thread_id",
///         "status",
///         "appended"
///     ],
///     "title": "ChatMessagesAppendResponse"
/// }
library chat_messages_append_response;

import 'exports.dart';
part 'chat_messages_append_response.freezed.dart';
part 'chat_messages_append_response.g.dart'; // ChatMessagesAppendResponse

@freezed
abstract class ChatMessagesAppendResponse with _$ChatMessagesAppendResponse {
  const ChatMessagesAppendResponse._();

  @jsonSerializable
  const factory ChatMessagesAppendResponse({
    /// threadId
    @JsonKey(name: ChatMessagesAppendResponse.threadIdKey_)
    required String threadId,

    /// status
    @JsonKey(name: ChatMessagesAppendResponse.statusKey_)
    required ChatThreadStatus status,

    /// appended
    @JsonKey(name: ChatMessagesAppendResponse.appendedKey_)
    required List<ChatMessageView> appended,
  }) = _ChatMessagesAppendResponse;

  factory ChatMessagesAppendResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagesAppendResponseFromJson(json);

  static const String threadIdKey_ = r'thread_id';

  static const String statusKey_ = r'status';

  static const String appendedKey_ = r'appended';
}
