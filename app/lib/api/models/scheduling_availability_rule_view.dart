/// SchedulingAvailabilityRuleView
/// {
///     "properties": {
///         "weekday": {
///             "type": "integer",
///             "title": "Weekday"
///         },
///         "start_local": {
///             "type": "string",
///             "format": "time",
///             "title": "Start Local"
///         },
///         "end_local": {
///             "type": "string",
///             "format": "time",
///             "title": "End Local"
///         },
///         "timezone": {
///             "type": "string",
///             "title": "Timezone"
///         },
///         "location_mode": {
///             "$ref": "#/components/schemas/AvailabilityLocationMode",
///             "default": "both"
///         },
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "weekday",
///         "start_local",
///         "end_local",
///         "timezone",
///         "id",
///         "pro_user_id",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "SchedulingAvailabilityRuleView"
/// }
library scheduling_availability_rule_view;

import 'exports.dart';
part 'scheduling_availability_rule_view.freezed.dart';
part 'scheduling_availability_rule_view.g.dart'; // SchedulingAvailabilityRuleView

@freezed
abstract class SchedulingAvailabilityRuleView
    with _$SchedulingAvailabilityRuleView {
  const SchedulingAvailabilityRuleView._();

  @jsonSerializable
  const factory SchedulingAvailabilityRuleView({
    /// weekday
    @JsonKey(name: SchedulingAvailabilityRuleView.weekdayKey_)
    required int weekday,

    /// startLocal
    @JsonKey(name: SchedulingAvailabilityRuleView.startLocalKey_)
    required String startLocal,

    /// endLocal
    @JsonKey(name: SchedulingAvailabilityRuleView.endLocalKey_)
    required String endLocal,

    /// timezone
    @JsonKey(name: SchedulingAvailabilityRuleView.timezoneKey_)
    required String timezone,

    /// locationMode
    @Default(AvailabilityLocationMode.both)
    @JsonKey(name: SchedulingAvailabilityRuleView.locationModeKey_)
    AvailabilityLocationMode locationMode,

    /// id
    @JsonKey(name: SchedulingAvailabilityRuleView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: SchedulingAvailabilityRuleView.proUserIdKey_)
    required String proUserId,

    /// createdAt
    @JsonKey(name: SchedulingAvailabilityRuleView.createdAtKey_)
    required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: SchedulingAvailabilityRuleView.updatedAtKey_)
    required DateTime updatedAt,
  }) = _SchedulingAvailabilityRuleView;

  factory SchedulingAvailabilityRuleView.fromJson(Map<String, dynamic> json) =>
      _$SchedulingAvailabilityRuleViewFromJson(json);

  static const String weekdayKey_ = r'weekday';

  static const String startLocalKey_ = r'start_local';

  static const String endLocalKey_ = r'end_local';

  static const String timezoneKey_ = r'timezone';

  static const String locationModeKey_ = r'location_mode';

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
