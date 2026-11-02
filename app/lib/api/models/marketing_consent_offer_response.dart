/// MarketingConsentOfferResponse
/// {
///     "properties": {
///         "offered": {
///             "type": "boolean",
///             "title": "Offered"
///         },
///         "reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reason"
///         },
///         "wording_version": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Wording Version"
///         },
///         "wording_text": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Wording Text"
///         },
///         "scope": {
///             "type": "string",
///             "default": "rawwers_organic",
///             "title": "Scope"
///         },
///         "terms": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MarketingTermView"
///             },
///             "title": "Terms"
///         },
///         "default_term_months": {
///             "type": "integer",
///             "default": 12,
///             "title": "Default Term Months"
///         },
///         "photographer_credit": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Photographer Credit"
///         },
///         "photos": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MarketingPhotoView"
///             },
///             "title": "Photos"
///         }
///     },
///     "type": "object",
///     "required": [
///         "offered"
///     ],
///     "title": "MarketingConsentOfferResponse"
/// }
library marketing_consent_offer_response;

import 'exports.dart';
part 'marketing_consent_offer_response.freezed.dart';
part 'marketing_consent_offer_response.g.dart'; // MarketingConsentOfferResponse

@freezed
abstract class MarketingConsentOfferResponse
    with _$MarketingConsentOfferResponse {
  const MarketingConsentOfferResponse._();

  @jsonSerializable
  const factory MarketingConsentOfferResponse({
    /// offered
    @JsonKey(name: MarketingConsentOfferResponse.offeredKey_)
    required bool offered,

    /// reason
    @JsonKey(name: MarketingConsentOfferResponse.reasonKey_) String? reason,

    /// wordingVersion
    @JsonKey(name: MarketingConsentOfferResponse.wordingVersionKey_)
    String? wordingVersion,

    /// wordingText
    @JsonKey(name: MarketingConsentOfferResponse.wordingTextKey_)
    String? wordingText,

    /// scope
    @Default('rawwers_organic')
    @JsonKey(name: MarketingConsentOfferResponse.scopeKey_)
    String scope,

    /// terms
    @JsonKey(name: MarketingConsentOfferResponse.termsKey_)
    List<MarketingTermView>? terms,

    /// defaultTermMonths
    @Default(12)
    @JsonKey(name: MarketingConsentOfferResponse.defaultTermMonthsKey_)
    int defaultTermMonths,

    /// photographerCredit
    @JsonKey(name: MarketingConsentOfferResponse.photographerCreditKey_)
    String? photographerCredit,

    /// photos
    @JsonKey(name: MarketingConsentOfferResponse.photosKey_)
    List<MarketingPhotoView>? photos,
  }) = _MarketingConsentOfferResponse;

  factory MarketingConsentOfferResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketingConsentOfferResponseFromJson(json);

  static const String offeredKey_ = r'offered';

  static const String reasonKey_ = r'reason';

  static const String wordingVersionKey_ = r'wording_version';

  static const String wordingTextKey_ = r'wording_text';

  static const String scopeKey_ = r'scope';

  static const String termsKey_ = r'terms';

  static const String defaultTermMonthsKey_ = r'default_term_months';

  static const String photographerCreditKey_ = r'photographer_credit';

  static const String photosKey_ = r'photos';
}
