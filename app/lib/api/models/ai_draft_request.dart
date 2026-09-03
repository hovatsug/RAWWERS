/// AIDraftRequest
/// {
///     "properties": {
///         "context": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Context"
///         }
///     },
///     "type": "object",
///     "title": "AIDraftRequest"
/// }
library ai_draft_request;

import 'exports.dart';
part 'ai_draft_request.freezed.dart';
part 'ai_draft_request.g.dart'; // AIDraftRequest

@freezed
abstract class AIDraftRequest with _$AIDraftRequest {
  const AIDraftRequest._();

  @jsonSerializable
  const factory AIDraftRequest({
    /// context
    @JsonKey(name: AIDraftRequest.contextKey_) String? context,
  }) = _AIDraftRequest;

  factory AIDraftRequest.fromJson(Map<String, dynamic> json) =>
      _$AIDraftRequestFromJson(json);

  static const String contextKey_ = r'context';
}
