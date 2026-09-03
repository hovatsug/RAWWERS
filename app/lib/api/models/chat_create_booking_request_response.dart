/// ChatCreateBookingRequestResponse
/// {
///     "properties": {
///         "booking_request": {
///             "$ref": "#/components/schemas/BookingRequestView"
///         }
///     },
///     "type": "object",
///     "required": [
///         "booking_request"
///     ],
///     "title": "ChatCreateBookingRequestResponse"
/// }
library chat_create_booking_request_response;

import 'exports.dart';
part 'chat_create_booking_request_response.freezed.dart';
part 'chat_create_booking_request_response.g.dart'; // ChatCreateBookingRequestResponse

@freezed
abstract class ChatCreateBookingRequestResponse
    with _$ChatCreateBookingRequestResponse {
  const ChatCreateBookingRequestResponse._();

  @jsonSerializable
  const factory ChatCreateBookingRequestResponse({
    /// bookingRequest
    @JsonKey(name: ChatCreateBookingRequestResponse.bookingRequestKey_)
    required BookingRequestView bookingRequest,
  }) = _ChatCreateBookingRequestResponse;

  factory ChatCreateBookingRequestResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ChatCreateBookingRequestResponseFromJson(json);

  static const String bookingRequestKey_ = r'booking_request';
}
