/// ChatThreadCreateRequest
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id"
///     ],
///     "title": "ChatThreadCreateRequest"
/// }
library chat_thread_create_request;

import 'exports.dart';
part 'chat_thread_create_request.freezed.dart';
part 'chat_thread_create_request.g.dart'; // ChatThreadCreateRequest

@freezed
abstract class ChatThreadCreateRequest with _$ChatThreadCreateRequest {
  const ChatThreadCreateRequest._();

  @jsonSerializable
  const factory ChatThreadCreateRequest({
    /// proUserId
    @JsonKey(name: ChatThreadCreateRequest.proUserIdKey_)
    required String proUserId,

    /// sessionId
    @JsonKey(name: ChatThreadCreateRequest.sessionIdKey_) String? sessionId,
  }) = _ChatThreadCreateRequest;

  factory ChatThreadCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadCreateRequestFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String sessionIdKey_ = r'session_id';
}
