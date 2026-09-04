/// PublicAvailabilityRuleView
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
///     "title": "PublicAvailabilityRuleView",
///     "description": "A weekly rule as the public profile endpoint exposes it.\n\nNamed apart from scheduling.AvailabilityRuleView deliberately. The two\nshared a name, and FastAPI's collision handling qualifies the schema\nkeys but leaves both titles identical - which collapsed them into one\nclass in the generated Dart client, silently keeping this shape for the\nscheduling endpoint that returns the other one."
/// }
library public_availability_rule_view;

import 'exports.dart';
part 'public_availability_rule_view.freezed.dart';
part 'public_availability_rule_view.g.dart'; // PublicAvailabilityRuleView

@freezed
abstract class PublicAvailabilityRuleView with _$PublicAvailabilityRuleView {
  const PublicAvailabilityRuleView._();

  @jsonSerializable
  const factory PublicAvailabilityRuleView({
    /// id
    @JsonKey(name: PublicAvailabilityRuleView.idKey_) required String id,

    /// dayOfWeek
    @JsonKey(name: PublicAvailabilityRuleView.dayOfWeekKey_)
    required int dayOfWeek,

    /// startTime
    @JsonKey(name: PublicAvailabilityRuleView.startTimeKey_)
    required String startTime,

    /// endTime
    @JsonKey(name: PublicAvailabilityRuleView.endTimeKey_)
    required String endTime,
  }) = _PublicAvailabilityRuleView;

  factory PublicAvailabilityRuleView.fromJson(Map<String, dynamic> json) =>
      _$PublicAvailabilityRuleViewFromJson(json);

  static const String idKey_ = r'id';

  static const String dayOfWeekKey_ = r'day_of_week';

  static const String startTimeKey_ = r'start_time';

  static const String endTimeKey_ = r'end_time';
}
