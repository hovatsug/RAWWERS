/// BookingTimeWindowsRequest
/// {
///     "properties": {
///         "client_timezone": {
///             "type": "string",
///             "title": "Client Timezone"
///         },
///         "windows": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/TimeWindowItem"
///             },
///             "title": "Windows"
///         }
///     },
///     "type": "object",
///     "required": [
///         "client_timezone"
///     ],
///     "title": "BookingTimeWindowsRequest"
/// }
library booking_time_windows_request;

import 'exports.dart';
part 'booking_time_windows_request.freezed.dart';
part 'booking_time_windows_request.g.dart'; // BookingTimeWindowsRequest

@freezed
abstract class BookingTimeWindowsRequest with _$BookingTimeWindowsRequest {
  const BookingTimeWindowsRequest._();

  @jsonSerializable
  const factory BookingTimeWindowsRequest({
    /// clientTimezone
    @JsonKey(name: BookingTimeWindowsRequest.clientTimezoneKey_)
    required String clientTimezone,

    /// windows
    @JsonKey(name: BookingTimeWindowsRequest.windowsKey_)
    List<TimeWindowItem>? windows,
  }) = _BookingTimeWindowsRequest;

  factory BookingTimeWindowsRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingTimeWindowsRequestFromJson(json);

  static const String clientTimezoneKey_ = r'client_timezone';

  static const String windowsKey_ = r'windows';
}
