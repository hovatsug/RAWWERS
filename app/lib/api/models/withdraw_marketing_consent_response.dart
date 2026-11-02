/// WithdrawMarketingConsentResponse
/// {
///     "properties": {
///         "withdrawn": {
///             "type": "integer",
///             "title": "Withdrawn"
///         }
///     },
///     "type": "object",
///     "required": [
///         "withdrawn"
///     ],
///     "title": "WithdrawMarketingConsentResponse"
/// }
library withdraw_marketing_consent_response;

import 'exports.dart';
part 'withdraw_marketing_consent_response.freezed.dart';
part 'withdraw_marketing_consent_response.g.dart'; // WithdrawMarketingConsentResponse

@freezed
abstract class WithdrawMarketingConsentResponse
    with _$WithdrawMarketingConsentResponse {
  const WithdrawMarketingConsentResponse._();

  @jsonSerializable
  const factory WithdrawMarketingConsentResponse({
    /// withdrawn
    @JsonKey(name: WithdrawMarketingConsentResponse.withdrawnKey_)
    required int withdrawn,
  }) = _WithdrawMarketingConsentResponse;

  factory WithdrawMarketingConsentResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$WithdrawMarketingConsentResponseFromJson(json);

  static const String withdrawnKey_ = r'withdrawn';
}
