/// BookingTimeWindowsResponse
/// {
///     "properties": {
///         "booking_request_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Booking Request Id"
///         },
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
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
///         "booking_request_id",
///         "id",
///         "client_timezone"
///     ],
///     "title": "BookingTimeWindowsResponse"
/// }
library booking_time_windows_response;

import 'exports.dart';
part 'booking_time_windows_response.freezed.dart';
part 'booking_time_windows_response.g.dart'; // BookingTimeWindowsResponse

@freezed
abstract class BookingTimeWindowsResponse with _$BookingTimeWindowsResponse {
  const BookingTimeWindowsResponse._();

  @jsonSerializable
  const factory BookingTimeWindowsResponse({
    /// bookingRequestId
    @JsonKey(name: BookingTimeWindowsResponse.bookingRequestIdKey_)
    required String bookingRequestId,

    /// id
    @JsonKey(name: BookingTimeWindowsResponse.idKey_) required String id,

    /// clientTimezone
    @JsonKey(name: BookingTimeWindowsResponse.clientTimezoneKey_)
    required String clientTimezone,

    /// windows
    @JsonKey(name: BookingTimeWindowsResponse.windowsKey_)
    List<TimeWindowItem>? windows,
  }) = _BookingTimeWindowsResponse;

  factory BookingTimeWindowsResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingTimeWindowsResponseFromJson(json);

  static const String bookingRequestIdKey_ = r'booking_request_id';

  static const String idKey_ = r'id';

  static const String clientTimezoneKey_ = r'client_timezone';

  static const String windowsKey_ = r'windows';
}
