/// ConfirmSlotRequest
/// {
///     "properties": {
///         "start_at_utc": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Start At Utc"
///         },
///         "end_at_utc": {
///             "type": "string",
///             "format": "date-time",
///             "title": "End At Utc"
///         }
///     },
///     "type": "object",
///     "required": [
///         "start_at_utc",
///         "end_at_utc"
///     ],
///     "title": "ConfirmSlotRequest"
/// }
library confirm_slot_request;

import 'exports.dart';
part 'confirm_slot_request.freezed.dart';
part 'confirm_slot_request.g.dart'; // ConfirmSlotRequest

@freezed
abstract class ConfirmSlotRequest with _$ConfirmSlotRequest {
  const ConfirmSlotRequest._();

  @jsonSerializable
  const factory ConfirmSlotRequest({
    /// startAtUtc
    @JsonKey(name: ConfirmSlotRequest.startAtUtcKey_)
    required DateTime startAtUtc,

    /// endAtUtc
    @JsonKey(name: ConfirmSlotRequest.endAtUtcKey_) required DateTime endAtUtc,
  }) = _ConfirmSlotRequest;

  factory ConfirmSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfirmSlotRequestFromJson(json);

  static const String startAtUtcKey_ = r'start_at_utc';

  static const String endAtUtcKey_ = r'end_at_utc';
}
