/// SchedulingPolicyUpdateRequest
/// {
///     "properties": {
///         "slot_length_minutes": {
///             "type": "integer",
///             "default": 60,
///             "title": "Slot Length Minutes"
///         },
///         "buffer_before_minutes": {
///             "type": "integer",
///             "default": 15,
///             "title": "Buffer Before Minutes"
///         },
///         "buffer_after_minutes": {
///             "type": "integer",
///             "default": 15,
///             "title": "Buffer After Minutes"
///         },
///         "advance_notice_hours": {
///             "type": "integer",
///             "default": 24,
///             "title": "Advance Notice Hours"
///         },
///         "max_bookings_per_day": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Max Bookings Per Day"
///         }
///     },
///     "type": "object",
///     "title": "SchedulingPolicyUpdateRequest"
/// }
library scheduling_policy_update_request;

import 'exports.dart';
part 'scheduling_policy_update_request.freezed.dart';
part 'scheduling_policy_update_request.g.dart'; // SchedulingPolicyUpdateRequest

@freezed
abstract class SchedulingPolicyUpdateRequest
    with _$SchedulingPolicyUpdateRequest {
  const SchedulingPolicyUpdateRequest._();

  @jsonSerializable
  const factory SchedulingPolicyUpdateRequest({
    /// slotLengthMinutes
    @Default(60)
    @JsonKey(name: SchedulingPolicyUpdateRequest.slotLengthMinutesKey_)
    int slotLengthMinutes,

    /// bufferBeforeMinutes
    @Default(15)
    @JsonKey(name: SchedulingPolicyUpdateRequest.bufferBeforeMinutesKey_)
    int bufferBeforeMinutes,

    /// bufferAfterMinutes
    @Default(15)
    @JsonKey(name: SchedulingPolicyUpdateRequest.bufferAfterMinutesKey_)
    int bufferAfterMinutes,

    /// advanceNoticeHours
    @Default(24)
    @JsonKey(name: SchedulingPolicyUpdateRequest.advanceNoticeHoursKey_)
    int advanceNoticeHours,

    /// maxBookingsPerDay
    @JsonKey(name: SchedulingPolicyUpdateRequest.maxBookingsPerDayKey_)
    int? maxBookingsPerDay,
  }) = _SchedulingPolicyUpdateRequest;

  factory SchedulingPolicyUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$SchedulingPolicyUpdateRequestFromJson(json);

  static const String slotLengthMinutesKey_ = r'slot_length_minutes';

  static const String bufferBeforeMinutesKey_ = r'buffer_before_minutes';

  static const String bufferAfterMinutesKey_ = r'buffer_after_minutes';

  static const String advanceNoticeHoursKey_ = r'advance_notice_hours';

  static const String maxBookingsPerDayKey_ = r'max_bookings_per_day';
}
