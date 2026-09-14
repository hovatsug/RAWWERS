/// AcceptBookingRequest
/// {
///     "properties": {
///         "client_credit_percent": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Client Credit Percent"
///         }
///     },
///     "type": "object",
///     "title": "AcceptBookingRequest",
///     "description": "Optional body on accepting a booking.\n\nEverything here has a default, so the endpoint stays callable with no body\nat all - which is how every existing caller invokes it."
/// }
library accept_booking_request;

import 'exports.dart';
part 'accept_booking_request.freezed.dart';
part 'accept_booking_request.g.dart'; // AcceptBookingRequest

@freezed
abstract class AcceptBookingRequest with _$AcceptBookingRequest {
  const AcceptBookingRequest._();

  @jsonSerializable
  const factory AcceptBookingRequest({
    /// clientCreditPercent
    @JsonKey(name: AcceptBookingRequest.clientCreditPercentKey_)
    int? clientCreditPercent,
  }) = _AcceptBookingRequest;

  factory AcceptBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$AcceptBookingRequestFromJson(json);

  static const String clientCreditPercentKey_ = r'client_credit_percent';
}
