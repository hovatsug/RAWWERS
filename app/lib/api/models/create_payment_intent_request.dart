/// CreatePaymentIntentRequest
/// {
///     "properties": {
///         "payment_method_types": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Payment Method Types"
///         },
///         "return_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Return Url"
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
///     "title": "CreatePaymentIntentRequest"
/// }
library create_payment_intent_request;

import 'exports.dart';
part 'create_payment_intent_request.freezed.dart';
part 'create_payment_intent_request.g.dart'; // CreatePaymentIntentRequest

@freezed
abstract class CreatePaymentIntentRequest with _$CreatePaymentIntentRequest {
  const CreatePaymentIntentRequest._();

  @jsonSerializable
  const factory CreatePaymentIntentRequest({
    /// paymentMethodTypes
    @JsonKey(name: CreatePaymentIntentRequest.paymentMethodTypesKey_)
    List<String>? paymentMethodTypes,

    /// returnUrl
    @JsonKey(name: CreatePaymentIntentRequest.returnUrlKey_) String? returnUrl,

    /// pointsToSpend
    @JsonKey(name: CreatePaymentIntentRequest.pointsToSpendKey_)
    int? pointsToSpend,
  }) = _CreatePaymentIntentRequest;

  factory CreatePaymentIntentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentIntentRequestFromJson(json);

  static const String paymentMethodTypesKey_ = r'payment_method_types';

  static const String returnUrlKey_ = r'return_url';

  static const String pointsToSpendKey_ = r'points_to_spend';
}
