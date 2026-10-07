/// ClientAvailabilityStart
/// {
///     "properties": {
///         "start_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Start At"
///         },
///         "local_time": {
///             "type": "string",
///             "title": "Local Time"
///         },
///         "end_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "End At"
///         },
///         "local_end_time": {
///             "type": "string",
///             "title": "Local End Time"
///         },
///         "label": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Label"
///         }
///     },
///     "type": "object",
///     "required": [
///         "start_at",
///         "local_time",
///         "end_at",
///         "local_end_time"
///     ],
///     "title": "ClientAvailabilityStart",
///     "description": "One time a shoot could start.\n\nBoth forms, because they answer different questions. `start_at` is the\ninstant, with the photographer's offset - what a booking request sends.\n`local_time` is the wall-clock time where the photographer is, \"10:00\" -\nwhat the client reads. An app that parses the instant gets it in UTC and\nwould show the time in the phone's zone, which is wrong for anyone\nbrowsing from somewhere else."
/// }
library client_availability_start;

import 'exports.dart';
part 'client_availability_start.freezed.dart';
part 'client_availability_start.g.dart'; // ClientAvailabilityStart

@freezed
abstract class ClientAvailabilityStart with _$ClientAvailabilityStart {
  const ClientAvailabilityStart._();

  @jsonSerializable
  const factory ClientAvailabilityStart({
    /// startAt
    @JsonKey(name: ClientAvailabilityStart.startAtKey_)
    required DateTime startAt,

    /// localTime
    @JsonKey(name: ClientAvailabilityStart.localTimeKey_)
    required String localTime,

    /// endAt
    @JsonKey(name: ClientAvailabilityStart.endAtKey_) required DateTime endAt,

    /// localEndTime
    @JsonKey(name: ClientAvailabilityStart.localEndTimeKey_)
    required String localEndTime,

    /// label
    @JsonKey(name: ClientAvailabilityStart.labelKey_) String? label,
  }) = _ClientAvailabilityStart;

  factory ClientAvailabilityStart.fromJson(Map<String, dynamic> json) =>
      _$ClientAvailabilityStartFromJson(json);

  static const String startAtKey_ = r'start_at';

  static const String localTimeKey_ = r'local_time';

  static const String endAtKey_ = r'end_at';

  static const String localEndTimeKey_ = r'local_end_time';

  static const String labelKey_ = r'label';
}
