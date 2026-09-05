/// ChatCloseRequest
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
///     "title": "ChatCloseRequest"
/// }
library chat_close_request;

import 'exports.dart';
part 'chat_close_request.freezed.dart';
part 'chat_close_request.g.dart'; // ChatCloseRequest

@freezed
abstract class ChatCloseRequest with _$ChatCloseRequest {
  const ChatCloseRequest._();

  @jsonSerializable
  const factory ChatCloseRequest({
    /// reason
    @JsonKey(name: ChatCloseRequest.reasonKey_) String? reason,
  }) = _ChatCloseRequest;

  factory ChatCloseRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatCloseRequestFromJson(json);

  static const String reasonKey_ = r'reason';
}
