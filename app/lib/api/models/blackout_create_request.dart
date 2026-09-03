/// BlackoutCreateRequest
/// {
///     "properties": {
///         "start_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Start At"
///         },
///         "end_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "End At"
///         },
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
///     "required": [
///         "start_at",
///         "end_at"
///     ],
///     "title": "BlackoutCreateRequest"
/// }
library blackout_create_request;

import 'exports.dart';
part 'blackout_create_request.freezed.dart';
part 'blackout_create_request.g.dart'; // BlackoutCreateRequest

@freezed
abstract class BlackoutCreateRequest with _$BlackoutCreateRequest {
  const BlackoutCreateRequest._();

  @jsonSerializable
  const factory BlackoutCreateRequest({
    /// startAt
    @JsonKey(name: BlackoutCreateRequest.startAtKey_) required DateTime startAt,

    /// endAt
    @JsonKey(name: BlackoutCreateRequest.endAtKey_) required DateTime endAt,

    /// reason
    @JsonKey(name: BlackoutCreateRequest.reasonKey_) String? reason,
  }) = _BlackoutCreateRequest;

  factory BlackoutCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$BlackoutCreateRequestFromJson(json);

  static const String startAtKey_ = r'start_at';

  static const String endAtKey_ = r'end_at';

  static const String reasonKey_ = r'reason';
}
