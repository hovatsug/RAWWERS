/// ClientPreferenceUpdateRequest
/// {
///     "properties": {
///         "preferred_niches": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Preferred Niches"
///         },
///         "budget_min": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Budget Min"
///         },
///         "budget_max": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Budget Max"
///         },
///         "style_tags": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Style Tags"
///         },
///         "location": {
///             "type": "object",
///             "title": "Location"
///         },
///         "consent_default": {
///             "$ref": "#/components/schemas/GigConsentLevel",
///             "default": "none"
///         }
///     },
///     "type": "object",
///     "title": "ClientPreferenceUpdateRequest"
/// }
library client_preference_update_request;

import 'exports.dart';
part 'client_preference_update_request.freezed.dart';
part 'client_preference_update_request.g.dart'; // ClientPreferenceUpdateRequest

@freezed
abstract class ClientPreferenceUpdateRequest
    with _$ClientPreferenceUpdateRequest {
  const ClientPreferenceUpdateRequest._();

  @jsonSerializable
  const factory ClientPreferenceUpdateRequest({
    /// preferredNiches
    @JsonKey(name: ClientPreferenceUpdateRequest.preferredNichesKey_)
    List<String>? preferredNiches,

    /// budgetMin
    @JsonKey(name: ClientPreferenceUpdateRequest.budgetMinKey_)
    dynamic? budgetMin,

    /// budgetMax
    @JsonKey(name: ClientPreferenceUpdateRequest.budgetMaxKey_)
    dynamic? budgetMax,

    /// styleTags
    @JsonKey(name: ClientPreferenceUpdateRequest.styleTagsKey_)
    List<String>? styleTags,

    /// location
    @JsonKey(name: ClientPreferenceUpdateRequest.locationKey_)
    Map<String, dynamic>? location,

    /// consentDefault
    @Default(GigConsentLevel.none)
    @JsonKey(name: ClientPreferenceUpdateRequest.consentDefaultKey_)
    GigConsentLevel consentDefault,
  }) = _ClientPreferenceUpdateRequest;

  factory ClientPreferenceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ClientPreferenceUpdateRequestFromJson(json);

  static const String preferredNichesKey_ = r'preferred_niches';

  static const String budgetMinKey_ = r'budget_min';

  static const String budgetMaxKey_ = r'budget_max';

  static const String styleTagsKey_ = r'style_tags';

  static const String locationKey_ = r'location';

  static const String consentDefaultKey_ = r'consent_default';
}
