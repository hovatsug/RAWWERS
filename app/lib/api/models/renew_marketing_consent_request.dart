/// RenewMarketingConsentRequest
/// {
///     "properties": {
///         "consent_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Consent Ids"
///         },
///         "term_months": {
///             "type": "integer",
///             "default": 12,
///             "title": "Term Months"
///         }
///     },
///     "type": "object",
///     "required": [
///         "consent_ids"
///     ],
///     "title": "RenewMarketingConsentRequest"
/// }
library renew_marketing_consent_request;

import 'exports.dart';
part 'renew_marketing_consent_request.freezed.dart';
part 'renew_marketing_consent_request.g.dart'; // RenewMarketingConsentRequest

@freezed
abstract class RenewMarketingConsentRequest
    with _$RenewMarketingConsentRequest {
  const RenewMarketingConsentRequest._();

  @jsonSerializable
  const factory RenewMarketingConsentRequest({
    /// consentIds
    @JsonKey(name: RenewMarketingConsentRequest.consentIdsKey_)
    required List<String> consentIds,

    /// termMonths
    @Default(12)
    @JsonKey(name: RenewMarketingConsentRequest.termMonthsKey_)
    int termMonths,
  }) = _RenewMarketingConsentRequest;

  factory RenewMarketingConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$RenewMarketingConsentRequestFromJson(json);

  static const String consentIdsKey_ = r'consent_ids';

  static const String termMonthsKey_ = r'term_months';
}
