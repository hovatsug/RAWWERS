/// ChatUnreadResponse
/// {
///     "properties": {
///         "threads": {
///             "type": "integer",
///             "title": "Threads"
///         },
///         "messages": {
///             "type": "integer",
///             "title": "Messages"
///         }
///     },
///     "type": "object",
///     "required": [
///         "threads",
///         "messages"
///     ],
///     "title": "ChatUnreadResponse",
///     "description": "The photographer's Messages badge."
/// }
library chat_unread_response;

import 'exports.dart';
part 'chat_unread_response.freezed.dart';
part 'chat_unread_response.g.dart'; // ChatUnreadResponse

@freezed
abstract class ChatUnreadResponse with _$ChatUnreadResponse {
  const ChatUnreadResponse._();

  @jsonSerializable
  const factory ChatUnreadResponse({
    /// threads
    @JsonKey(name: ChatUnreadResponse.threadsKey_) required int threads,

    /// messages
    @JsonKey(name: ChatUnreadResponse.messagesKey_) required int messages,
  }) = _ChatUnreadResponse;

  factory ChatUnreadResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatUnreadResponseFromJson(json);

  static const String threadsKey_ = r'threads';

  static const String messagesKey_ = r'messages';
}
