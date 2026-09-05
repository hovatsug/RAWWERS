/// ProOnboardingStartRequest
/// {
///     "properties": {
///         "city": {
///             "type": "string",
///             "title": "City"
///         },
///         "country": {
///             "type": "string",
///             "title": "Country"
///         },
///         "invite_code": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Invite Code"
///         }
///     },
///     "type": "object",
///     "required": [
///         "city",
///         "country"
///     ],
///     "title": "ProOnboardingStartRequest"
/// }
library pro_onboarding_start_request;

import 'exports.dart';
part 'pro_onboarding_start_request.freezed.dart';
part 'pro_onboarding_start_request.g.dart'; // ProOnboardingStartRequest

@freezed
abstract class ProOnboardingStartRequest with _$ProOnboardingStartRequest {
  const ProOnboardingStartRequest._();

  @jsonSerializable
  const factory ProOnboardingStartRequest({
    /// city
    @JsonKey(name: ProOnboardingStartRequest.cityKey_) required String city,

    /// country
    @JsonKey(name: ProOnboardingStartRequest.countryKey_)
    required String country,

    /// inviteCode
    @JsonKey(name: ProOnboardingStartRequest.inviteCodeKey_) String? inviteCode,
  }) = _ProOnboardingStartRequest;

  factory ProOnboardingStartRequest.fromJson(Map<String, dynamic> json) =>
      _$ProOnboardingStartRequestFromJson(json);

  static const String cityKey_ = r'city';

  static const String countryKey_ = r'country';

  static const String inviteCodeKey_ = r'invite_code';
}
