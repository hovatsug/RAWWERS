/// RescheduleRequest
/// {
///     "properties": {
///         "client_timezone": {
///             "type": "string",
///             "title": "Client Timezone"
///         },
///         "proposed_windows": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/TimeWindowItem"
///             },
///             "title": "Proposed Windows"
///         }
///     },
///     "type": "object",
///     "required": [
///         "client_timezone"
///     ],
///     "title": "RescheduleRequest"
/// }
library reschedule_request;

import 'exports.dart';
part 'reschedule_request.freezed.dart';
part 'reschedule_request.g.dart'; // RescheduleRequest

@freezed
abstract class RescheduleRequest with _$RescheduleRequest {
  const RescheduleRequest._();

  @jsonSerializable
  const factory RescheduleRequest({
    /// clientTimezone
    @JsonKey(name: RescheduleRequest.clientTimezoneKey_)
    required String clientTimezone,

    /// proposedWindows
    @JsonKey(name: RescheduleRequest.proposedWindowsKey_)
    List<TimeWindowItem>? proposedWindows,
  }) = _RescheduleRequest;

  factory RescheduleRequest.fromJson(Map<String, dynamic> json) =>
      _$RescheduleRequestFromJson(json);

  static const String clientTimezoneKey_ = r'client_timezone';

  static const String proposedWindowsKey_ = r'proposed_windows';
}
