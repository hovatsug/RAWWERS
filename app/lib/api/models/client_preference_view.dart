/// ClientPreferenceView
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
///             "$ref": "#/components/schemas/GigConsentLevel"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "consent_default",
///         "updated_at"
///     ],
///     "title": "ClientPreferenceView"
/// }
library client_preference_view;

import 'exports.dart';
part 'client_preference_view.freezed.dart';
part 'client_preference_view.g.dart'; // ClientPreferenceView

@freezed
abstract class ClientPreferenceView with _$ClientPreferenceView {
  const ClientPreferenceView._();

  @jsonSerializable
  const factory ClientPreferenceView({
    /// preferredNiches
    @JsonKey(name: ClientPreferenceView.preferredNichesKey_)
    List<String>? preferredNiches,

    /// budgetMin
    @JsonKey(name: ClientPreferenceView.budgetMinKey_) String? budgetMin,

    /// budgetMax
    @JsonKey(name: ClientPreferenceView.budgetMaxKey_) String? budgetMax,

    /// styleTags
    @JsonKey(name: ClientPreferenceView.styleTagsKey_) List<String>? styleTags,

    /// location
    @JsonKey(name: ClientPreferenceView.locationKey_)
    Map<String, dynamic>? location,

    /// consentDefault
    @JsonKey(name: ClientPreferenceView.consentDefaultKey_)
    required GigConsentLevel consentDefault,

    /// updatedAt
    @JsonKey(name: ClientPreferenceView.updatedAtKey_)
    required DateTime updatedAt,
  }) = _ClientPreferenceView;

  factory ClientPreferenceView.fromJson(Map<String, dynamic> json) =>
      _$ClientPreferenceViewFromJson(json);

  static const String preferredNichesKey_ = r'preferred_niches';

  static const String budgetMinKey_ = r'budget_min';

  static const String budgetMaxKey_ = r'budget_max';

  static const String styleTagsKey_ = r'style_tags';

  static const String locationKey_ = r'location';

  static const String consentDefaultKey_ = r'consent_default';

  static const String updatedAtKey_ = r'updated_at';
}
