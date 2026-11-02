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
  }) = _GrantMarketingConsentResponse;

  factory GrantMarketingConsentResponse.fromJson(Map<String, dynamic> json) =>
      _$GrantMarketingConsentResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String creditKey_ = r'credit';
}
