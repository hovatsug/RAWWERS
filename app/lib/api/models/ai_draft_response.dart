/// AIDraftResponse
/// {
///     "properties": {
///         "content": {
///             "type": "string",
///             "title": "Content"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "required": [
///         "content"
///     ],
///     "title": "AIDraftResponse"
/// }
library ai_draft_response;

import 'exports.dart';
part 'ai_draft_response.freezed.dart';
part 'ai_draft_response.g.dart'; // AIDraftResponse

@freezed
abstract class AIDraftResponse with _$AIDraftResponse {
  const AIDraftResponse._();

  @jsonSerializable
  const factory AIDraftResponse({
    /// content
    @JsonKey(name: AIDraftResponse.contentKey_) required String content,

    /// metadata
    @JsonKey(name: AIDraftResponse.metadataKey_) Map<String, dynamic>? metadata,
  }) = _AIDraftResponse;

  factory AIDraftResponse.fromJson(Map<String, dynamic> json) =>
      _$AIDraftResponseFromJson(json);

  static const String contentKey_ = r'content';

  static const String metadataKey_ = r'metadata';
}
