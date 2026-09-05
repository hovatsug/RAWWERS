/// SchedulingSlotView
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
///         },
///         "timezone": {
///             "type": "string",
///             "title": "Timezone"
///         },
///         "start_local": {
///             "type": "string",
///             "title": "Start Local"
///         },
///         "end_local": {
///             "type": "string",
///             "title": "End Local"
///         }
///     },
///     "type": "object",
///     "required": [
///         "start_at_utc",
///         "end_at_utc",
///         "timezone",
///         "start_local",
///         "end_local"
///     ],
///     "title": "SchedulingSlotView"
/// }
library scheduling_slot_view;

import 'exports.dart';
part 'scheduling_slot_view.freezed.dart';
part 'scheduling_slot_view.g.dart'; // SchedulingSlotView

@freezed
abstract class SchedulingSlotView with _$SchedulingSlotView {
  const SchedulingSlotView._();

  @jsonSerializable
  const factory SchedulingSlotView({
    /// startAtUtc
    @JsonKey(name: SchedulingSlotView.startAtUtcKey_)
    required DateTime startAtUtc,

    /// endAtUtc
    @JsonKey(name: SchedulingSlotView.endAtUtcKey_) required DateTime endAtUtc,

    /// timezone
    @JsonKey(name: SchedulingSlotView.timezoneKey_) required String timezone,

    /// startLocal
    @JsonKey(name: SchedulingSlotView.startLocalKey_)
    required String startLocal,

    /// endLocal
    @JsonKey(name: SchedulingSlotView.endLocalKey_) required String endLocal,
  }) = _SchedulingSlotView;

  factory SchedulingSlotView.fromJson(Map<String, dynamic> json) =>
      _$SchedulingSlotViewFromJson(json);

  static const String startAtUtcKey_ = r'start_at_utc';

  static const String endAtUtcKey_ = r'end_at_utc';

  static const String timezoneKey_ = r'timezone';

  static const String startLocalKey_ = r'start_local';

  static const String endLocalKey_ = r'end_local';
}
