/// CreatePaymentIntentResponse
/// {
///     "properties": {
///         "payment_intent_client_secret": {
///             "type": "string",
///             "title": "Payment Intent Client Secret"
///         },
///         "payment_intent_id": {
///             "type": "string",
///             "title": "Payment Intent Id"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "discount_amount": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Discount Amount"
///         },
///         "points_spent": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Points Spent"
///         }
///     },
///     "type": "object",
///     "required": [
///         "payment_intent_client_secret",
///         "payment_intent_id",
///         "status"
///     ],
///     "title": "CreatePaymentIntentResponse"
/// }
library create_payment_intent_response;

import 'exports.dart';
part 'create_payment_intent_response.freezed.dart';
part 'create_payment_intent_response.g.dart'; // CreatePaymentIntentResponse

@freezed
abstract class CreatePaymentIntentResponse with _$CreatePaymentIntentResponse {
  const CreatePaymentIntentResponse._();

  @jsonSerializable
  const factory CreatePaymentIntentResponse({
    /// paymentIntentClientSecret
    @JsonKey(name: CreatePaymentIntentResponse.paymentIntentClientSecretKey_)
    required String paymentIntentClientSecret,

    /// paymentIntentId
    @JsonKey(name: CreatePaymentIntentResponse.paymentIntentIdKey_)
    required String paymentIntentId,

    /// status
    @JsonKey(name: CreatePaymentIntentResponse.statusKey_)
    required String status,

    /// discountAmount
    @JsonKey(name: CreatePaymentIntentResponse.discountAmountKey_)
    String? discountAmount,

    /// pointsSpent
    @JsonKey(name: CreatePaymentIntentResponse.pointsSpentKey_)
    int? pointsSpent,
  }) = _CreatePaymentIntentResponse;

  factory CreatePaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentIntentResponseFromJson(json);

  static const String paymentIntentClientSecretKey_ =
      r'payment_intent_client_secret';

  static const String paymentIntentIdKey_ = r'payment_intent_id';

  static const String statusKey_ = r'status';

  static const String discountAmountKey_ = r'discount_amount';

  static const String pointsSpentKey_ = r'points_spent';
}
