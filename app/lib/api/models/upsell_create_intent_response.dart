/// UpsellCreateIntentResponse
/// {
///     "properties": {
///         "purchase_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Purchase Id"
///         },
///         "payment_intent_id": {
///             "type": "string",
///             "title": "Payment Intent Id"
///         },
///         "payment_intent_client_secret": {
///             "type": "string",
///             "title": "Payment Intent Client Secret"
///         },
///         "status": {
///             "$ref": "#/components/schemas/UpsellPurchaseStatus"
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
///         "purchase_id",
///         "payment_intent_id",
///         "payment_intent_client_secret",
///         "status"
///     ],
///     "title": "UpsellCreateIntentResponse"
/// }
library upsell_create_intent_response;

import 'exports.dart';
part 'upsell_create_intent_response.freezed.dart';
part 'upsell_create_intent_response.g.dart'; // UpsellCreateIntentResponse

@freezed
abstract class UpsellCreateIntentResponse with _$UpsellCreateIntentResponse {
  const UpsellCreateIntentResponse._();

  @jsonSerializable
  const factory UpsellCreateIntentResponse({
    /// purchaseId
    @JsonKey(name: UpsellCreateIntentResponse.purchaseIdKey_)
    required String purchaseId,

    /// paymentIntentId
    @JsonKey(name: UpsellCreateIntentResponse.paymentIntentIdKey_)
    required String paymentIntentId,

    /// paymentIntentClientSecret
    @JsonKey(name: UpsellCreateIntentResponse.paymentIntentClientSecretKey_)
    required String paymentIntentClientSecret,

    /// status
    @JsonKey(name: UpsellCreateIntentResponse.statusKey_)
    required UpsellPurchaseStatus status,

    /// discountAmount
    @JsonKey(name: UpsellCreateIntentResponse.discountAmountKey_)
    String? discountAmount,

    /// pointsSpent
    @JsonKey(name: UpsellCreateIntentResponse.pointsSpentKey_) int? pointsSpent,
  }) = _UpsellCreateIntentResponse;

  factory UpsellCreateIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$UpsellCreateIntentResponseFromJson(json);

  static const String purchaseIdKey_ = r'purchase_id';

  static const String paymentIntentIdKey_ = r'payment_intent_id';

  static const String paymentIntentClientSecretKey_ =
      r'payment_intent_client_secret';

  static const String statusKey_ = r'status';

  static const String discountAmountKey_ = r'discount_amount';

  static const String pointsSpentKey_ = r'points_spent';
}
