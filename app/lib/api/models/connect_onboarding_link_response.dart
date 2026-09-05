/// ConnectOnboardingLinkResponse
/// {
///     "properties": {
///         "url": {
///             "type": "string",
///             "title": "Url"
///         },
///         "stripe_account_id": {
///             "type": "string",
///             "title": "Stripe Account Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "url",
///         "stripe_account_id"
///     ],
///     "title": "ConnectOnboardingLinkResponse",
///     "description": "A single-use hosted-onboarding URL.\n\nNot cached anywhere: Stripe account links expire within minutes and\nare consumed on first use, so a stored one is a broken one."
/// }
library connect_onboarding_link_response;

import 'exports.dart';
part 'connect_onboarding_link_response.freezed.dart';
part 'connect_onboarding_link_response.g.dart'; // ConnectOnboardingLinkResponse

@freezed
abstract class ConnectOnboardingLinkResponse
    with _$ConnectOnboardingLinkResponse {
  const ConnectOnboardingLinkResponse._();

  @jsonSerializable
  const factory ConnectOnboardingLinkResponse({
    /// url
    @JsonKey(name: ConnectOnboardingLinkResponse.urlKey_) required String url,

    /// stripeAccountId
    @JsonKey(name: ConnectOnboardingLinkResponse.stripeAccountIdKey_)
    required String stripeAccountId,
  }) = _ConnectOnboardingLinkResponse;

  factory ConnectOnboardingLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$ConnectOnboardingLinkResponseFromJson(json);

  static const String urlKey_ = r'url';

  static const String stripeAccountIdKey_ = r'stripe_account_id';
}
