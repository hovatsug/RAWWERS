/// ClientBookingPayResponse
/// {
///     "properties": {
///         "booking_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Booking Id"
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
///         },
///         "mode": {
///             "type": "string",
///             "title": "Mode"
///         },
///         "credit": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Credit"
///         },
///         "amount": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Amount"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         }
///     },
///     "type": "object",
///     "required": [
///         "booking_id",
///         "gig_id",
///         "payment_intent_id",
///         "payment_intent_client_secret",
///         "mode",
///         "currency"
///     ],
///     "title": "ClientBookingPayResponse"
/// }
library client_booking_pay_response;

import 'exports.dart';
part 'client_booking_pay_response.freezed.dart';
part 'client_booking_pay_response.g.dart'; // ClientBookingPayResponse

@freezed
abstract class ClientBookingPayResponse with _$ClientBookingPayResponse {
  const ClientBookingPayResponse._();

  @jsonSerializable
  const factory ClientBookingPayResponse({
    /// bookingId
    @JsonKey(name: ClientBookingPayResponse.bookingIdKey_)
    required String bookingId,

    /// gigId
    @JsonKey(name: ClientBookingPayResponse.gigIdKey_) required String gigId,

    /// paymentIntentId
    @JsonKey(name: ClientBookingPayResponse.paymentIntentIdKey_)
    required String paymentIntentId,

    /// paymentIntentClientSecret
    @JsonKey(name: ClientBookingPayResponse.paymentIntentClientSecretKey_)
    required String paymentIntentClientSecret,

    /// mode
    @JsonKey(name: ClientBookingPayResponse.modeKey_) required String mode,

    /// credit
    @Default('0.00')
    @JsonKey(name: ClientBookingPayResponse.creditKey_)
    String credit,

    /// amount
    @JsonKey(name: ClientBookingPayResponse.amountKey_) String? amount,

    /// currency
    @JsonKey(name: ClientBookingPayResponse.currencyKey_)
    required String currency,
  }) = _ClientBookingPayResponse;

  factory ClientBookingPayResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientBookingPayResponseFromJson(json);

  static const String bookingIdKey_ = r'booking_id';

  static const String gigIdKey_ = r'gig_id';

  static const String paymentIntentIdKey_ = r'payment_intent_id';

  static const String paymentIntentClientSecretKey_ =
      r'payment_intent_client_secret';

  static const String modeKey_ = r'mode';

  static const String creditKey_ = r'credit';

  static const String amountKey_ = r'amount';

  static const String currencyKey_ = r'currency';
}
