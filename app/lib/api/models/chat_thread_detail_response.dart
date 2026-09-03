/// ChatThreadDetailResponse
/// {
///     "properties": {
///         "thread": {
///             "$ref": "#/components/schemas/ChatThreadSummary"
///         },
///         "messages": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ChatMessageV1View"
///             },
///             "title": "Messages"
///         },
///         "lead_profile": {
///             "type": "object",
///             "title": "Lead Profile"
///         }
///     },
///     "type": "object",
///     "required": [
///         "thread"
///     ],
///     "title": "ChatThreadDetailResponse"
/// }
library chat_thread_detail_response;

import 'exports.dart';
part 'chat_thread_detail_response.freezed.dart';
part 'chat_thread_detail_response.g.dart'; // ChatThreadDetailResponse

@freezed
abstract class ChatThreadDetailResponse with _$ChatThreadDetailResponse {
  const ChatThreadDetailResponse._();

  @jsonSerializable
  const factory ChatThreadDetailResponse({
    /// thread
    @JsonKey(name: ChatThreadDetailResponse.threadKey_)
    required ChatThreadSummary thread,

    /// messages
    @JsonKey(name: ChatThreadDetailResponse.messagesKey_)
    List<ChatMessageV1View>? messages,

    /// leadProfile
    @JsonKey(name: ChatThreadDetailResponse.leadProfileKey_)
    Map<String, dynamic>? leadProfile,
  }) = _ChatThreadDetailResponse;

  factory ChatThreadDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadDetailResponseFromJson(json);

  static const String threadKey_ = r'thread';

  static const String messagesKey_ = r'messages';

  static const String leadProfileKey_ = r'lead_profile';
}
