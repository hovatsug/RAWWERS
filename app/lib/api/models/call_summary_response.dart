/// CallSummaryResponse
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "summary": {
///             "type": "string",
///             "title": "Summary"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "summary",
///         "metadata"
///     ],
///     "title": "CallSummaryResponse"
/// }
library call_summary_response;

import 'exports.dart';
part 'call_summary_response.freezed.dart';
part 'call_summary_response.g.dart'; // CallSummaryResponse

@freezed
abstract class CallSummaryResponse with _$CallSummaryResponse {
  const CallSummaryResponse._();

  @jsonSerializable
  const factory CallSummaryResponse({
    /// id
    @JsonKey(name: CallSummaryResponse.idKey_) required String id,

    /// summary
    @JsonKey(name: CallSummaryResponse.summaryKey_) required String summary,

    /// metadata
    @JsonKey(name: CallSummaryResponse.metadataKey_)
    required Map<String, dynamic> metadata,
  }) = _CallSummaryResponse;

  factory CallSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$CallSummaryResponseFromJson(json);

  static const String idKey_ = r'id';

  static const String summaryKey_ = r'summary';

  static const String metadataKey_ = r'metadata';
}
