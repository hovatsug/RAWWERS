/// GrantMarketingConsentResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MarketingConsentView"
///             },
///             "title": "Items"
///         },
///         "credit": {
///             "type": "integer",
///             "title": "Credit"
///         },
///         "credit_amount": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Credit Amount"
///         },
///         "currency": {
///             "type": "string",
///             "default": "EUR",
///             "title": "Currency"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items",
///         "credit"
///     ],
///     "title": "GrantMarketingConsentResponse"
/// }
library grant_marketing_consent_response;

import 'exports.dart';
part 'grant_marketing_consent_response.freezed.dart';
part 'grant_marketing_consent_response.g.dart'; // GrantMarketingConsentResponse

@freezed
abstract class GrantMarketingConsentResponse
    with _$GrantMarketingConsentResponse {
  const GrantMarketingConsentResponse._();

  @jsonSerializable
  const factory GrantMarketingConsentResponse({
    /// items
    @JsonKey(name: GrantMarketingConsentResponse.itemsKey_)
    required List<MarketingConsentView> items,

    /// credit
    @JsonKey(name: GrantMarketingConsentResponse.creditKey_)
    required int credit,

    /// creditAmount
    @Default('0.00')
    @JsonKey(name: GrantMarketingConsentResponse.creditAmountKey_)
    String creditAmount,

    /// currency
    @Default('EUR')
    @JsonKey(name: GrantMarketingConsentResponse.currencyKey_)
    String currency,
  }) = _GrantMarketingConsentResponse;

  factory GrantMarketingConsentResponse.fromJson(Map<String, dynamic> json) =>
      _$GrantMarketingConsentResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String creditKey_ = r'credit';

  static const String creditAmountKey_ = r'credit_amount';

  static const String currencyKey_ = r'currency';
}
