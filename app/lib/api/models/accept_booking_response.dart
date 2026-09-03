/// AcceptBookingResponse
/// {
///     "properties": {
///         "booking_request": {
///             "$ref": "#/components/schemas/BookingRequestView"
///         },
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "payment_intent_id": {
///             "type": "string",
///             "title": "Payment Intent Id"
///         },
///         "payment_intent_client_secret": {
///             "type": "string",
///             "title": "Payment Intent Client Secret"
///         }
///     },
///     "type": "object",
///     "required": [
///         "booking_request",
///         "gig_id",
///         "payment_intent_id",
///         "payment_intent_client_secret"
///     ],
///     "title": "AcceptBookingResponse"
/// }
library accept_booking_response;

import 'exports.dart';
part 'accept_booking_response.freezed.dart';
part 'accept_booking_response.g.dart'; // AcceptBookingResponse

@freezed
abstract class AcceptBookingResponse with _$AcceptBookingResponse {
  const AcceptBookingResponse._();

  @jsonSerializable
  const factory AcceptBookingResponse({
    /// bookingRequest
    @JsonKey(name: AcceptBookingResponse.bookingRequestKey_)
    required BookingRequestView bookingRequest,

    /// gigId
    @JsonKey(name: AcceptBookingResponse.gigIdKey_) required String gigId,

    /// paymentIntentId
    @JsonKey(name: AcceptBookingResponse.paymentIntentIdKey_)
    required String paymentIntentId,

    /// paymentIntentClientSecret
    @JsonKey(name: AcceptBookingResponse.paymentIntentClientSecretKey_)
    required String paymentIntentClientSecret,
  }) = _AcceptBookingResponse;

  factory AcceptBookingResponse.fromJson(Map<String, dynamic> json) =>
      _$AcceptBookingResponseFromJson(json);

  static const String bookingRequestKey_ = r'booking_request';

  static const String gigIdKey_ = r'gig_id';

  static const String paymentIntentIdKey_ = r'payment_intent_id';

  static const String paymentIntentClientSecretKey_ =
      r'payment_intent_client_secret';
}
