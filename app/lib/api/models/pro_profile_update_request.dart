/// ProProfileUpdateRequest
/// {
///     "properties": {
///         "display_name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Display Name"
///         },
///         "headline": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Headline"
///         },
///         "cover_media_asset_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Cover Media Asset Id"
///         },
///         "bio": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Bio"
///         },
///         "city": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "City"
///         },
///         "country": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Country"
///         },
///         "languages": {
///             "anyOf": [
///                 {
///                     "type": "array",
///                     "items": {
///                         "type": "string"
///                     }
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Languages"
///         },
///         "styles": {
///             "anyOf": [
///                 {
///                     "type": "array",
///                     "items": {
///                         "type": "string"
///                     }
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Styles"
///         },
///         "gear": {
///             "anyOf": [
///                 {
///                     "type": "object"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Gear"
///         },
///         "travel_radius_km": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Travel Radius Km"
///         }
///     },
///     "type": "object",
///     "title": "ProProfileUpdateRequest"
/// }
library pro_profile_update_request;

import 'exports.dart';
part 'pro_profile_update_request.freezed.dart';
part 'pro_profile_update_request.g.dart'; // ProProfileUpdateRequest

@freezed
abstract class ProProfileUpdateRequest with _$ProProfileUpdateRequest {
  const ProProfileUpdateRequest._();

  @jsonSerializable
  const factory ProProfileUpdateRequest({
    /// displayName
    @JsonKey(name: ProProfileUpdateRequest.displayNameKey_) String? displayName,

    /// headline
    @JsonKey(name: ProProfileUpdateRequest.headlineKey_) String? headline,

    /// coverMediaAssetId
    @JsonKey(name: ProProfileUpdateRequest.coverMediaAssetIdKey_)
    String? coverMediaAssetId,

    /// bio
    @JsonKey(name: ProProfileUpdateRequest.bioKey_) String? bio,

    /// city
    @JsonKey(name: ProProfileUpdateRequest.cityKey_) String? city,

    /// country
    @JsonKey(name: ProProfileUpdateRequest.countryKey_) String? country,

    /// languages
    @JsonKey(name: ProProfileUpdateRequest.languagesKey_)
    List<String>? languages,

    /// styles
    @JsonKey(name: ProProfileUpdateRequest.stylesKey_) List<String>? styles,

    /// gear
    @JsonKey(name: ProProfileUpdateRequest.gearKey_) Map<String, dynamic>? gear,

    /// travelRadiusKm
    @JsonKey(name: ProProfileUpdateRequest.travelRadiusKmKey_)
    int? travelRadiusKm,
  }) = _ProProfileUpdateRequest;

  factory ProProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProProfileUpdateRequestFromJson(json);

  static const String displayNameKey_ = r'display_name';

  static const String headlineKey_ = r'headline';

  static const String coverMediaAssetIdKey_ = r'cover_media_asset_id';

  static const String bioKey_ = r'bio';

  static const String cityKey_ = r'city';

  static const String countryKey_ = r'country';

  static const String languagesKey_ = r'languages';

  static const String stylesKey_ = r'styles';

  static const String gearKey_ = r'gear';

  static const String travelRadiusKmKey_ = r'travel_radius_km';
}
