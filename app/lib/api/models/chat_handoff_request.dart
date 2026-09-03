/// ChatHandoffRequest
/// {
///     "properties": {
///         "reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reason"
///         }
///     },
///     "type": "object",
///     "title": "ChatHandoffRequest"
/// }
library chat_handoff_request;

import 'exports.dart';
part 'chat_handoff_request.freezed.dart';
part 'chat_handoff_request.g.dart'; // ChatHandoffRequest

@freezed
abstract class ChatHandoffRequest with _$ChatHandoffRequest {
  const ChatHandoffRequest._();

  @jsonSerializable
  const factory ChatHandoffRequest({
    /// reason
    @JsonKey(name: ChatHandoffRequest.reasonKey_) String? reason,
  }) = _ChatHandoffRequest;

  factory ChatHandoffRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatHandoffRequestFromJson(json);

  static const String reasonKey_ = r'reason';
}
