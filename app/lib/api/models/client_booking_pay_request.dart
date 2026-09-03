/// ClientBookingPayRequest
/// {
///     "properties": {
///         "payment_mode": {
///             "type": "string",
///             "pattern": "^(full|deposit)$",
///             "title": "Payment Mode"
///         },
///         "points_to_spend": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Points To Spend"
///         }
///     },
///     "type": "object",
///     "required": [
///         "payment_mode"
///     ],
///     "title": "ClientBookingPayRequest"
/// }
library client_booking_pay_request;

import 'exports.dart';
part 'client_booking_pay_request.freezed.dart';
part 'client_booking_pay_request.g.dart'; // ClientBookingPayRequest

@freezed
abstract class ClientBookingPayRequest with _$ClientBookingPayRequest {
  const ClientBookingPayRequest._();

  @jsonSerializable
  const factory ClientBookingPayRequest({
    /// paymentMode
    @JsonKey(name: ClientBookingPayRequest.paymentModeKey_)
    required String paymentMode,

    /// pointsToSpend
    @JsonKey(name: ClientBookingPayRequest.pointsToSpendKey_)
    int? pointsToSpend,
  }) = _ClientBookingPayRequest;

  factory ClientBookingPayRequest.fromJson(Map<String, dynamic> json) =>
      _$ClientBookingPayRequestFromJson(json);

  static const String paymentModeKey_ = r'payment_mode';

  static const String pointsToSpendKey_ = r'points_to_spend';
}
