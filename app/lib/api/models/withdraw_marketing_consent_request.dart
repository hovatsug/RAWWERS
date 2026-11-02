/// WithdrawMarketingConsentRequest
/// {
///     "properties": {
///         "consent_ids": {
///             "anyOf": [
///                 {
///                     "type": "array",
///                     "items": {
///                         "type": "string",
///                         "format": "uuid"
///                     }
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Consent Ids"
///         },
///         "all": {
///             "type": "boolean",
///             "default": false,
///             "title": "All"
///         }
///     },
///     "type": "object",
///     "title": "WithdrawMarketingConsentRequest"
/// }
library withdraw_marketing_consent_request;

import 'exports.dart';
part 'withdraw_marketing_consent_request.freezed.dart';
part 'withdraw_marketing_consent_request.g.dart'; // WithdrawMarketingConsentRequest

@freezed
abstract class WithdrawMarketingConsentRequest
    with _$WithdrawMarketingConsentRequest {
  const WithdrawMarketingConsentRequest._();

  @jsonSerializable
  const factory WithdrawMarketingConsentRequest({
    /// consentIds
    @JsonKey(name: WithdrawMarketingConsentRequest.consentIdsKey_)
    List<String>? consentIds,

    /// all
    @Default(false)
    @JsonKey(name: WithdrawMarketingConsentRequest.allKey_)
    bool all,
  }) = _WithdrawMarketingConsentRequest;

  factory WithdrawMarketingConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawMarketingConsentRequestFromJson(json);

  static const String consentIdsKey_ = r'consent_ids';

  static const String allKey_ = r'all';
}
