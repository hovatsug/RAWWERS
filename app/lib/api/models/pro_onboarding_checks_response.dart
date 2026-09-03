/// ProOnboardingChecksResponse
/// {
///     "properties": {
///         "status": {
///             "$ref": "#/components/schemas/ProOnboardingStatus"
///         },
///         "checks": {
///             "type": "object",
///             "title": "Checks"
///         },
///         "missing": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Missing"
///         }
///     },
///     "type": "object",
///     "required": [
///         "status"
///     ],
///     "title": "ProOnboardingChecksResponse"
/// }
library pro_onboarding_checks_response;

import 'exports.dart';
part 'pro_onboarding_checks_response.freezed.dart';
part 'pro_onboarding_checks_response.g.dart'; // ProOnboardingChecksResponse

@freezed
abstract class ProOnboardingChecksResponse with _$ProOnboardingChecksResponse {
  const ProOnboardingChecksResponse._();

  @jsonSerializable
  const factory ProOnboardingChecksResponse({
    /// status
    @JsonKey(name: ProOnboardingChecksResponse.statusKey_)
    required ProOnboardingStatus status,

    /// checks
    @JsonKey(name: ProOnboardingChecksResponse.checksKey_)
    Map<String, dynamic>? checks,

    /// missing
    @JsonKey(name: ProOnboardingChecksResponse.missingKey_)
    List<String>? missing,
  }) = _ProOnboardingChecksResponse;

  factory ProOnboardingChecksResponse.fromJson(Map<String, dynamic> json) =>
      _$ProOnboardingChecksResponseFromJson(json);

  static const String statusKey_ = r'status';

  static const String checksKey_ = r'checks';

  static const String missingKey_ = r'missing';
}
