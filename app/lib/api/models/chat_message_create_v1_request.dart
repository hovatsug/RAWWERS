/// ChatMessageCreateV1Request
/// {
///     "properties": {
///         "content": {
///             "type": "string",
///             "maxLength": 4000,
///             "minLength": 1,
///             "title": "Content"
///         }
///     },
///     "type": "object",
///     "required": [
///         "content"
///     ],
///     "title": "ChatMessageCreateV1Request"
/// }
library chat_message_create_v1_request;

import 'exports.dart';
part 'chat_message_create_v1_request.freezed.dart';
part 'chat_message_create_v1_request.g.dart'; // ChatMessageCreateV1Request

@freezed
abstract class ChatMessageCreateV1Request with _$ChatMessageCreateV1Request {
  const ChatMessageCreateV1Request._();

  @jsonSerializable
  const factory ChatMessageCreateV1Request({
    /// content
    @JsonKey(name: ChatMessageCreateV1Request.contentKey_)
    required String content,
  }) = _ChatMessageCreateV1Request;

  factory ChatMessageCreateV1Request.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageCreateV1RequestFromJson(json);

  static const String contentKey_ = r'content';
}
