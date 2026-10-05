/// ClientAvailabilityDay
/// {
///     "properties": {
///         "date": {
///             "type": "string",
///             "format": "date",
///             "title": "Date"
///         },
///         "open": {
///             "type": "boolean",
///             "title": "Open"
///         },
///         "start_times": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientAvailabilityStart"
///             },
///             "title": "Start Times"
///         }
///     },
///     "type": "object",
///     "required": [
///         "date",
///         "open"
///     ],
///     "title": "ClientAvailabilityDay",
///     "description": "One day of a photographer's calendar, as a client may see it.\n\nOpen or not, and when a shoot of the chosen package could start. Never\nwhy a day is closed: blocked time, other clients' bookings and a full day\nall read the same, because none of them is the client's business."
/// }
library client_availability_day;

import 'exports.dart';
part 'client_availability_day.freezed.dart';
part 'client_availability_day.g.dart'; // ClientAvailabilityDay

@freezed
abstract class ClientAvailabilityDay with _$ClientAvailabilityDay {
  const ClientAvailabilityDay._();

  @jsonSerializable
  const factory ClientAvailabilityDay({
    /// date
    @JsonKey(name: ClientAvailabilityDay.dateKey_) required DateTime date,

    /// open
    @JsonKey(name: ClientAvailabilityDay.openKey_) required bool open,

    /// startTimes
    @JsonKey(name: ClientAvailabilityDay.startTimesKey_)
    List<ClientAvailabilityStart>? startTimes,
  }) = _ClientAvailabilityDay;

  factory ClientAvailabilityDay.fromJson(Map<String, dynamic> json) =>
      _$ClientAvailabilityDayFromJson(json);

  static const String dateKey_ = r'date';

  static const String openKey_ = r'open';

  static const String startTimesKey_ = r'start_times';
}
