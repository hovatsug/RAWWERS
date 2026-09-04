/// AvailabilityRuleView
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
///     "title": "AvailabilityRuleView"
/// }
library availability_rule_view;

import 'exports.dart';
part 'availability_rule_view.freezed.dart';
part 'availability_rule_view.g.dart'; // AvailabilityRuleView

@freezed
abstract class AvailabilityRuleView with _$AvailabilityRuleView {
  const AvailabilityRuleView._();

  @jsonSerializable
  const factory AvailabilityRuleView({
    /// weekday
    @JsonKey(name: AvailabilityRuleView.weekdayKey_) required int weekday,

    /// startLocal
    @JsonKey(name: AvailabilityRuleView.startLocalKey_)
    required String startLocal,

    /// endLocal
    @JsonKey(name: AvailabilityRuleView.endLocalKey_) required String endLocal,

    /// timezone
    @JsonKey(name: AvailabilityRuleView.timezoneKey_) required String timezone,

    /// locationMode
    @Default(AvailabilityLocationMode.both)
    @JsonKey(name: AvailabilityRuleView.locationModeKey_)
    AvailabilityLocationMode locationMode,

    /// id
    @JsonKey(name: AvailabilityRuleView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: AvailabilityRuleView.proUserIdKey_)
    required String proUserId,

    /// createdAt
    @JsonKey(name: AvailabilityRuleView.createdAtKey_)
    required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: AvailabilityRuleView.updatedAtKey_)
    required DateTime updatedAt,
  }) = _AvailabilityRuleView;

  factory AvailabilityRuleView.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityRuleViewFromJson(json);

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
