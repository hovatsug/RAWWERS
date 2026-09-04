/// OnboardingAvailabilityRuleView
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
///     "title": "OnboardingAvailabilityRuleView"
/// }
library onboarding_availability_rule_view;

import 'exports.dart';
part 'onboarding_availability_rule_view.freezed.dart';
part 'onboarding_availability_rule_view.g.dart'; // OnboardingAvailabilityRuleView

@freezed
abstract class OnboardingAvailabilityRuleView
    with _$OnboardingAvailabilityRuleView {
  const OnboardingAvailabilityRuleView._();

  @jsonSerializable
  const factory OnboardingAvailabilityRuleView({
    /// id
    @JsonKey(name: OnboardingAvailabilityRuleView.idKey_) required String id,

    /// dayOfWeek
    @JsonKey(name: OnboardingAvailabilityRuleView.dayOfWeekKey_)
    required int dayOfWeek,

    /// startTime
    @JsonKey(name: OnboardingAvailabilityRuleView.startTimeKey_)
    required String startTime,

    /// endTime
    @JsonKey(name: OnboardingAvailabilityRuleView.endTimeKey_)
    required String endTime,
  }) = _OnboardingAvailabilityRuleView;

  factory OnboardingAvailabilityRuleView.fromJson(Map<String, dynamic> json) =>
      _$OnboardingAvailabilityRuleViewFromJson(json);

  static const String idKey_ = r'id';

  static const String dayOfWeekKey_ = r'day_of_week';

  static const String startTimeKey_ = r'start_time';

  static const String endTimeKey_ = r'end_time';
}
