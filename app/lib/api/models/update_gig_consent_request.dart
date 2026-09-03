/// UpdateGigConsentRequest
/// {
///     "properties": {
///         "consent_level": {
///             "$ref": "#/components/schemas/GigConsentLevel"
///         },
///         "scope": {
///             "type": "object",
///             "title": "Scope"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "consent_level"
///     ],
///     "title": "UpdateGigConsentRequest"
/// }
library update_gig_consent_request;

import 'exports.dart';
part 'update_gig_consent_request.freezed.dart';
part 'update_gig_consent_request.g.dart'; // UpdateGigConsentRequest

@freezed
abstract class UpdateGigConsentRequest with _$UpdateGigConsentRequest {
  const UpdateGigConsentRequest._();

  @jsonSerializable
  const factory UpdateGigConsentRequest({
    /// consentLevel
    @JsonKey(name: UpdateGigConsentRequest.consentLevelKey_)
    required GigConsentLevel consentLevel,

    /// scope
    @JsonKey(name: UpdateGigConsentRequest.scopeKey_)
    Map<String, dynamic>? scope,

    /// reason
    @JsonKey(name: UpdateGigConsentRequest.reasonKey_) String? reason,
  }) = _UpdateGigConsentRequest;

  factory UpdateGigConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGigConsentRequestFromJson(json);

  static const String consentLevelKey_ = r'consent_level';

  static const String scopeKey_ = r'scope';

  static const String reasonKey_ = r'reason';
}
