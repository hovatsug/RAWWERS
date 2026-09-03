/// app__schemas__onboarding__AvailabilityRuleView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "day_of_week": {
///             "type": "integer",
///             "title": "Day Of Week"
///         },
///         "start_time": {
///             "type": "string",
///             "format": "time",
///             "title": "Start Time"
///         },
///         "end_time": {
///             "type": "string",
///             "format": "time",
///             "title": "End Time"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "day_of_week",
///         "start_time",
///         "end_time"
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
    /// id
    @JsonKey(name: AvailabilityRuleView.idKey_) required String id,

    /// dayOfWeek
    @JsonKey(name: AvailabilityRuleView.dayOfWeekKey_) required int dayOfWeek,

    /// startTime
    @JsonKey(name: AvailabilityRuleView.startTimeKey_)
    required String startTime,

    /// endTime
    @JsonKey(name: AvailabilityRuleView.endTimeKey_) required String endTime,
  }) = _AvailabilityRuleView;

  factory AvailabilityRuleView.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityRuleViewFromJson(json);

  static const String idKey_ = r'id';

  static const String dayOfWeekKey_ = r'day_of_week';

  static const String startTimeKey_ = r'start_time';

  static const String endTimeKey_ = r'end_time';
}
