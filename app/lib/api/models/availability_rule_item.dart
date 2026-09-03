/// AvailabilityRuleItem
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "weekday",
///         "start_local",
///         "end_local",
///         "timezone"
///     ],
///     "title": "AvailabilityRuleItem"
/// }
library availability_rule_item;

import 'exports.dart';
part 'availability_rule_item.freezed.dart';
part 'availability_rule_item.g.dart'; // AvailabilityRuleItem

@freezed
abstract class AvailabilityRuleItem with _$AvailabilityRuleItem {
  const AvailabilityRuleItem._();

  @jsonSerializable
  const factory AvailabilityRuleItem({
    /// weekday
    @JsonKey(name: AvailabilityRuleItem.weekdayKey_) required int weekday,

    /// startLocal
    @JsonKey(name: AvailabilityRuleItem.startLocalKey_)
    required String startLocal,

    /// endLocal
    @JsonKey(name: AvailabilityRuleItem.endLocalKey_) required String endLocal,

    /// timezone
    @JsonKey(name: AvailabilityRuleItem.timezoneKey_) required String timezone,

    /// locationMode
    @Default(AvailabilityLocationMode.both)
    @JsonKey(name: AvailabilityRuleItem.locationModeKey_)
    AvailabilityLocationMode locationMode,
  }) = _AvailabilityRuleItem;

  factory AvailabilityRuleItem.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityRuleItemFromJson(json);

  static const String weekdayKey_ = r'weekday';

  static const String startLocalKey_ = r'start_local';

  static const String endLocalKey_ = r'end_local';

  static const String timezoneKey_ = r'timezone';

  static const String locationModeKey_ = r'location_mode';
}
