/// AvailabilityRuleInput
/// {
///     "properties": {
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
///         "day_of_week",
///         "start_time",
///         "end_time"
///     ],
///     "title": "AvailabilityRuleInput"
/// }
library availability_rule_input;

import 'exports.dart';
part 'availability_rule_input.freezed.dart';
part 'availability_rule_input.g.dart'; // AvailabilityRuleInput

@freezed
abstract class AvailabilityRuleInput with _$AvailabilityRuleInput {
  const AvailabilityRuleInput._();

  @jsonSerializable
  const factory AvailabilityRuleInput({
    /// dayOfWeek
    @JsonKey(name: AvailabilityRuleInput.dayOfWeekKey_) required int dayOfWeek,

    /// startTime
    @JsonKey(name: AvailabilityRuleInput.startTimeKey_)
    required String startTime,

    /// endTime
    @JsonKey(name: AvailabilityRuleInput.endTimeKey_) required String endTime,
  }) = _AvailabilityRuleInput;

  factory AvailabilityRuleInput.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityRuleInputFromJson(json);

  static const String dayOfWeekKey_ = r'day_of_week';

  static const String startTimeKey_ = r'start_time';

  static const String endTimeKey_ = r'end_time';
}
