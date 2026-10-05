/// ClientAvailabilityResponse
/// {
///     "properties": {
///         "timezone": {
///             "type": "string",
///             "title": "Timezone"
///         },
///         "has_schedule": {
///             "type": "boolean",
///             "title": "Has Schedule"
///         },
///         "notice_hours": {
///             "type": "integer",
///             "title": "Notice Hours"
///         },
///         "days": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientAvailabilityDay"
///             },
///             "title": "Days"
///         }
///     },
///     "type": "object",
///     "required": [
///         "timezone",
///         "has_schedule",
///         "notice_hours"
///     ],
///     "title": "ClientAvailabilityResponse"
/// }
library client_availability_response;

import 'exports.dart';
part 'client_availability_response.freezed.dart';
part 'client_availability_response.g.dart'; // ClientAvailabilityResponse

@freezed
abstract class ClientAvailabilityResponse with _$ClientAvailabilityResponse {
  const ClientAvailabilityResponse._();

  @jsonSerializable
  const factory ClientAvailabilityResponse({
    /// timezone
    @JsonKey(name: ClientAvailabilityResponse.timezoneKey_)
    required String timezone,

    /// hasSchedule
    @JsonKey(name: ClientAvailabilityResponse.hasScheduleKey_)
    required bool hasSchedule,

    /// noticeHours
    @JsonKey(name: ClientAvailabilityResponse.noticeHoursKey_)
    required int noticeHours,

    /// days
    @JsonKey(name: ClientAvailabilityResponse.daysKey_)
    List<ClientAvailabilityDay>? days,
  }) = _ClientAvailabilityResponse;

  factory ClientAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientAvailabilityResponseFromJson(json);

  static const String timezoneKey_ = r'timezone';

  static const String hasScheduleKey_ = r'has_schedule';

  static const String noticeHoursKey_ = r'notice_hours';

  static const String daysKey_ = r'days';
}
