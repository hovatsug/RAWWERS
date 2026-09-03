/// ChatThreadCreateResponse
/// {
///     "properties": {
///         "thread_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Thread Id"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ChatThreadStatus"
///         }
///     },
///     "type": "object",
///     "required": [
///         "thread_id",
///         "status"
///     ],
///     "title": "ChatThreadCreateResponse"
/// }
library chat_thread_create_response;

import 'exports.dart';
part 'chat_thread_create_response.freezed.dart';
part 'chat_thread_create_response.g.dart'; // ChatThreadCreateResponse

@freezed
abstract class ChatThreadCreateResponse with _$ChatThreadCreateResponse {
  const ChatThreadCreateResponse._();

  @jsonSerializable
  const factory ChatThreadCreateResponse({
    /// threadId
    @JsonKey(name: ChatThreadCreateResponse.threadIdKey_)
    required String threadId,

    /// status
    @JsonKey(name: ChatThreadCreateResponse.statusKey_)
    required ChatThreadStatus status,
  }) = _ChatThreadCreateResponse;

  factory ChatThreadCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadCreateResponseFromJson(json);

  static const String threadIdKey_ = r'thread_id';

  static const String statusKey_ = r'status';
}
