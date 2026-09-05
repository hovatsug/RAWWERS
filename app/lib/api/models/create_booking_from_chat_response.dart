/// CreateBookingFromChatResponse
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
///     "title": "CreateBookingFromChatResponse"
/// }
library create_booking_from_chat_response;

import 'exports.dart';
part 'create_booking_from_chat_response.freezed.dart';
part 'create_booking_from_chat_response.g.dart'; // CreateBookingFromChatResponse

@freezed
abstract class CreateBookingFromChatResponse
    with _$CreateBookingFromChatResponse {
  const CreateBookingFromChatResponse._();

  @jsonSerializable
  const factory CreateBookingFromChatResponse({
    /// bookingRequest
    @JsonKey(name: CreateBookingFromChatResponse.bookingRequestKey_)
    required BookingRequestView bookingRequest,
  }) = _CreateBookingFromChatResponse;

  factory CreateBookingFromChatResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingFromChatResponseFromJson(json);

  static const String bookingRequestKey_ = r'booking_request';
}
