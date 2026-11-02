/// GrantMarketingConsentRequest
/// {
///     "properties": {
///         "media_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Media Asset Ids"
///         },
///         "term_months": {
///             "type": "integer",
///             "default": 12,
///             "title": "Term Months"
///         },
///         "people_confirmed": {
///             "type": "boolean",
///             "default": false,
///             "title": "People Confirmed"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_ids"
///     ],
///     "title": "GrantMarketingConsentRequest"
/// }
library grant_marketing_consent_request;

import 'exports.dart';
part 'grant_marketing_consent_request.freezed.dart';
part 'grant_marketing_consent_request.g.dart'; // GrantMarketingConsentRequest

@freezed
abstract class GrantMarketingConsentRequest
    with _$GrantMarketingConsentRequest {
  const GrantMarketingConsentRequest._();

  @jsonSerializable
  const factory GrantMarketingConsentRequest({
    /// mediaAssetIds
    @JsonKey(name: GrantMarketingConsentRequest.mediaAssetIdsKey_)
    required List<String> mediaAssetIds,

    /// termMonths
    @Default(12)
    @JsonKey(name: GrantMarketingConsentRequest.termMonthsKey_)
    int termMonths,

    /// peopleConfirmed
    @Default(false)
    @JsonKey(name: GrantMarketingConsentRequest.peopleConfirmedKey_)
    bool peopleConfirmed,
  }) = _GrantMarketingConsentRequest;

  factory GrantMarketingConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$GrantMarketingConsentRequestFromJson(json);

  static const String mediaAssetIdsKey_ = r'media_asset_ids';

  static const String termMonthsKey_ = r'term_months';

  static const String peopleConfirmedKey_ = r'people_confirmed';
}
