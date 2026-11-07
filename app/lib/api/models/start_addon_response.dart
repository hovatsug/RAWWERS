/// StartAddonResponse
/// {
///     "properties": {
///         "addon_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Addon Id"
///         },
///         "amount": {
///             "type": "string",
///             "title": "Amount"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "payment_intent_client_secret": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Payment Intent Client Secret"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         }
///     },
///     "type": "object",
///     "required": [
///         "addon_id",
///         "amount",
///         "currency",
///         "status"
///     ],
///     "title": "StartAddonResponse"
/// }
library start_addon_response;

import 'exports.dart';
part 'start_addon_response.freezed.dart';
part 'start_addon_response.g.dart'; // StartAddonResponse

@freezed
abstract class StartAddonResponse with _$StartAddonResponse {
  const StartAddonResponse._();

  @jsonSerializable
  const factory StartAddonResponse({
    /// addonId
    @JsonKey(name: StartAddonResponse.addonIdKey_) required String addonId,

    /// amount
    @JsonKey(name: StartAddonResponse.amountKey_) required String amount,

    /// currency
    @JsonKey(name: StartAddonResponse.currencyKey_) required String currency,

    /// paymentIntentClientSecret
    @JsonKey(name: StartAddonResponse.paymentIntentClientSecretKey_)
    String? paymentIntentClientSecret,

    /// status
    @JsonKey(name: StartAddonResponse.statusKey_) required String status,
  }) = _StartAddonResponse;

  factory StartAddonResponse.fromJson(Map<String, dynamic> json) =>
      _$StartAddonResponseFromJson(json);

  static const String addonIdKey_ = r'addon_id';

  static const String amountKey_ = r'amount';

  static const String currencyKey_ = r'currency';

  static const String paymentIntentClientSecretKey_ =
      r'payment_intent_client_secret';

  static const String statusKey_ = r'status';
}
