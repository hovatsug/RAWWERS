/// SchedulingPolicyView
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "slot_length_minutes": {
///             "type": "integer",
///             "title": "Slot Length Minutes"
///         },
///         "buffer_before_minutes": {
///             "type": "integer",
///             "title": "Buffer Before Minutes"
///         },
///         "buffer_after_minutes": {
///             "type": "integer",
///             "title": "Buffer After Minutes"
///         },
///         "advance_notice_hours": {
///             "type": "integer",
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
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "slot_length_minutes",
///         "buffer_before_minutes",
///         "buffer_after_minutes",
///         "advance_notice_hours",
///         "updated_at"
///     ],
///     "title": "SchedulingPolicyView"
/// }
library scheduling_policy_view;

import 'exports.dart';
part 'scheduling_policy_view.freezed.dart';
part 'scheduling_policy_view.g.dart'; // SchedulingPolicyView

@freezed
abstract class SchedulingPolicyView with _$SchedulingPolicyView {
  const SchedulingPolicyView._();

  @jsonSerializable
  const factory SchedulingPolicyView({
    /// proUserId
    @JsonKey(name: SchedulingPolicyView.proUserIdKey_)
    required String proUserId,

    /// slotLengthMinutes
    @JsonKey(name: SchedulingPolicyView.slotLengthMinutesKey_)
    required int slotLengthMinutes,

    /// bufferBeforeMinutes
    @JsonKey(name: SchedulingPolicyView.bufferBeforeMinutesKey_)
    required int bufferBeforeMinutes,

    /// bufferAfterMinutes
    @JsonKey(name: SchedulingPolicyView.bufferAfterMinutesKey_)
    required int bufferAfterMinutes,

    /// advanceNoticeHours
    @JsonKey(name: SchedulingPolicyView.advanceNoticeHoursKey_)
    required int advanceNoticeHours,

    /// maxBookingsPerDay
    @JsonKey(name: SchedulingPolicyView.maxBookingsPerDayKey_)
    int? maxBookingsPerDay,

    /// updatedAt
    @JsonKey(name: SchedulingPolicyView.updatedAtKey_)
    required DateTime updatedAt,
  }) = _SchedulingPolicyView;

  factory SchedulingPolicyView.fromJson(Map<String, dynamic> json) =>
      _$SchedulingPolicyViewFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String slotLengthMinutesKey_ = r'slot_length_minutes';

  static const String bufferBeforeMinutesKey_ = r'buffer_before_minutes';

  static const String bufferAfterMinutesKey_ = r'buffer_after_minutes';

  static const String advanceNoticeHoursKey_ = r'advance_notice_hours';

  static const String maxBookingsPerDayKey_ = r'max_bookings_per_day';

  static const String updatedAtKey_ = r'updated_at';
}
