/// ChatMessageCreateRequest
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
///     "title": "ChatMessageCreateRequest"
/// }
library chat_message_create_request;

import 'exports.dart';
part 'chat_message_create_request.freezed.dart';
part 'chat_message_create_request.g.dart'; // ChatMessageCreateRequest

@freezed
abstract class ChatMessageCreateRequest with _$ChatMessageCreateRequest {
  const ChatMessageCreateRequest._();

  @jsonSerializable
  const factory ChatMessageCreateRequest({
    /// content
    @JsonKey(name: ChatMessageCreateRequest.contentKey_)
    required String content,
  }) = _ChatMessageCreateRequest;

  factory ChatMessageCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageCreateRequestFromJson(json);

  static const String contentKey_ = r'content';
}
