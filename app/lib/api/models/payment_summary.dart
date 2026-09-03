/// PaymentSummary
/// {
///     "properties": {
///         "status": {
///             "$ref": "#/components/schemas/PaymentStatus"
///         },
///         "stripe_payment_intent_id": {
///             "type": "string",
///             "title": "Stripe Payment Intent Id"
///         },
///         "amount": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "last_error": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Last Error"
///         }
///     },
///     "type": "object",
///     "required": [
///         "status",
///         "stripe_payment_intent_id",
///         "amount",
///         "currency"
///     ],
///     "title": "PaymentSummary"
/// }
library payment_summary;

import 'exports.dart';
part 'payment_summary.freezed.dart';
part 'payment_summary.g.dart'; // PaymentSummary

@freezed
abstract class PaymentSummary with _$PaymentSummary {
  const PaymentSummary._();

  @jsonSerializable
  const factory PaymentSummary({
    /// status
    @JsonKey(name: PaymentSummary.statusKey_) required PaymentStatus status,

    /// stripePaymentIntentId
    @JsonKey(name: PaymentSummary.stripePaymentIntentIdKey_)
    required String stripePaymentIntentId,

    /// amount
    @JsonKey(name: PaymentSummary.amountKey_) required String amount,

    /// currency
    @JsonKey(name: PaymentSummary.currencyKey_) required String currency,

    /// lastError
    @JsonKey(name: PaymentSummary.lastErrorKey_) String? lastError,
  }) = _PaymentSummary;

  factory PaymentSummary.fromJson(Map<String, dynamic> json) =>
      _$PaymentSummaryFromJson(json);

  static const String statusKey_ = r'status';

  static const String stripePaymentIntentIdKey_ = r'stripe_payment_intent_id';

  static const String amountKey_ = r'amount';

  static const String currencyKey_ = r'currency';

  static const String lastErrorKey_ = r'last_error';
}
