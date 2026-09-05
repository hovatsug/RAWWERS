/// ProProfileView
/// {
///     "properties": {
///         "user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "User Id"
///         },
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
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Languages"
///         },
///         "styles": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Styles"
///         },
///         "gear": {
///             "type": "object",
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
///         },
///         "is_accepting_bookings": {
///             "type": "boolean",
///             "title": "Is Accepting Bookings"
///         },
///         "completeness_score": {
///             "type": "integer",
///             "title": "Completeness Score"
///         },
///         "kyc_status": {
///             "type": "string",
///             "title": "Kyc Status"
///         }
///     },
///     "type": "object",
///     "required": [
///         "user_id",
///         "is_accepting_bookings",
///         "completeness_score",
///         "kyc_status"
///     ],
///     "title": "ProProfileView"
/// }
library pro_profile_view;

import 'exports.dart';
part 'pro_profile_view.freezed.dart';
part 'pro_profile_view.g.dart'; // ProProfileView

@freezed
abstract class ProProfileView with _$ProProfileView {
  const ProProfileView._();

  @jsonSerializable
  const factory ProProfileView({
    /// userId
    @JsonKey(name: ProProfileView.userIdKey_) required String userId,

    /// displayName
    @JsonKey(name: ProProfileView.displayNameKey_) String? displayName,

    /// headline
    @JsonKey(name: ProProfileView.headlineKey_) String? headline,

    /// coverMediaAssetId
    @JsonKey(name: ProProfileView.coverMediaAssetIdKey_)
    String? coverMediaAssetId,

    /// bio
    @JsonKey(name: ProProfileView.bioKey_) String? bio,

    /// city
    @JsonKey(name: ProProfileView.cityKey_) String? city,

    /// country
    @JsonKey(name: ProProfileView.countryKey_) String? country,

    /// languages
    @JsonKey(name: ProProfileView.languagesKey_) List<String>? languages,

    /// styles
    @JsonKey(name: ProProfileView.stylesKey_) List<String>? styles,

    /// gear
    @JsonKey(name: ProProfileView.gearKey_) Map<String, dynamic>? gear,

    /// travelRadiusKm
    @JsonKey(name: ProProfileView.travelRadiusKmKey_) int? travelRadiusKm,

    /// isAcceptingBookings
    @JsonKey(name: ProProfileView.isAcceptingBookingsKey_)
    required bool isAcceptingBookings,

    /// completenessScore
    @JsonKey(name: ProProfileView.completenessScoreKey_)
    required int completenessScore,

    /// kycStatus
    @JsonKey(name: ProProfileView.kycStatusKey_) required String kycStatus,
  }) = _ProProfileView;

  factory ProProfileView.fromJson(Map<String, dynamic> json) =>
      _$ProProfileViewFromJson(json);

  static const String userIdKey_ = r'user_id';

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

  static const String isAcceptingBookingsKey_ = r'is_accepting_bookings';

  static const String completenessScoreKey_ = r'completeness_score';

  static const String kycStatusKey_ = r'kyc_status';
}
