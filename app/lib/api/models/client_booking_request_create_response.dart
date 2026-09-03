/// ClientBookingRequestCreateResponse
/// {
///     "properties": {
///         "booking_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Booking Id"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         }
///     },
///     "type": "object",
///     "required": [
///         "booking_id",
///         "status"
///     ],
///     "title": "ClientBookingRequestCreateResponse"
/// }
library client_booking_request_create_response;

import 'exports.dart';
part 'client_booking_request_create_response.freezed.dart';
part 'client_booking_request_create_response.g.dart'; // ClientBookingRequestCreateResponse

@freezed
abstract class ClientBookingRequestCreateResponse
    with _$ClientBookingRequestCreateResponse {
  const ClientBookingRequestCreateResponse._();

  @jsonSerializable
  const factory ClientBookingRequestCreateResponse({
    /// bookingId
    @JsonKey(name: ClientBookingRequestCreateResponse.bookingIdKey_)
    required String bookingId,

    /// status
    @JsonKey(name: ClientBookingRequestCreateResponse.statusKey_)
    required String status,
  }) = _ClientBookingRequestCreateResponse;

  factory ClientBookingRequestCreateResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ClientBookingRequestCreateResponseFromJson(json);

  static const String bookingIdKey_ = r'booking_id';

  static const String statusKey_ = r'status';
}
