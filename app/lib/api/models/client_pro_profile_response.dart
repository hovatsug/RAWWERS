/// ClientProProfileResponse
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
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
///         "cover_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Cover Url"
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
///         "styles": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Styles"
///         },
///         "avg_rating": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Avg Rating"
///         },
///         "review_count": {
///             "type": "integer",
///             "title": "Review Count"
///         },
///         "portfolio_photo_count": {
///             "type": "integer",
///             "title": "Portfolio Photo Count"
///         },
///         "portfolio_video_count": {
///             "type": "integer",
///             "title": "Portfolio Video Count"
///         },
///         "packages": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientProfilePackage"
///             },
///             "title": "Packages"
///         },
///         "portfolio_preview_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Portfolio Preview Asset Ids"
///         },
///         "portfolio_preview": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientPortfolioItem"
///             },
///             "title": "Portfolio Preview"
///         },
///         "is_guest_view": {
///             "type": "boolean",
///             "default": false,
///             "title": "Is Guest View"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "avg_rating",
///         "review_count",
///         "portfolio_photo_count",
///         "portfolio_video_count"
///     ],
///     "title": "ClientProProfileResponse"
/// }
library client_pro_profile_response;

import 'exports.dart';
part 'client_pro_profile_response.freezed.dart';
part 'client_pro_profile_response.g.dart'; // ClientProProfileResponse

@freezed
abstract class ClientProProfileResponse with _$ClientProProfileResponse {
  const ClientProProfileResponse._();

  @jsonSerializable
  const factory ClientProProfileResponse({
    /// proUserId
    @JsonKey(name: ClientProProfileResponse.proUserIdKey_)
    required String proUserId,

    /// displayName
    @JsonKey(name: ClientProProfileResponse.displayNameKey_)
    String? displayName,

    /// headline
    @JsonKey(name: ClientProProfileResponse.headlineKey_) String? headline,

    /// coverMediaAssetId
    @JsonKey(name: ClientProProfileResponse.coverMediaAssetIdKey_)
    String? coverMediaAssetId,

    /// coverUrl
    @JsonKey(name: ClientProProfileResponse.coverUrlKey_) String? coverUrl,

    /// bio
    @JsonKey(name: ClientProProfileResponse.bioKey_) String? bio,

    /// city
    @JsonKey(name: ClientProProfileResponse.cityKey_) String? city,

    /// country
    @JsonKey(name: ClientProProfileResponse.countryKey_) String? country,

    /// styles
    @JsonKey(name: ClientProProfileResponse.stylesKey_) List<String>? styles,

    /// avgRating
    @JsonKey(name: ClientProProfileResponse.avgRatingKey_)
    required String avgRating,

    /// reviewCount
    @JsonKey(name: ClientProProfileResponse.reviewCountKey_)
    required int reviewCount,

    /// portfolioPhotoCount
    @JsonKey(name: ClientProProfileResponse.portfolioPhotoCountKey_)
    required int portfolioPhotoCount,

    /// portfolioVideoCount
    @JsonKey(name: ClientProProfileResponse.portfolioVideoCountKey_)
    required int portfolioVideoCount,

    /// packages
    @JsonKey(name: ClientProProfileResponse.packagesKey_)
    List<ClientProfilePackage>? packages,

    /// portfolioPreviewAssetIds
    @JsonKey(name: ClientProProfileResponse.portfolioPreviewAssetIdsKey_)
    List<String>? portfolioPreviewAssetIds,

    /// portfolioPreview
    @JsonKey(name: ClientProProfileResponse.portfolioPreviewKey_)
    List<ClientPortfolioItem>? portfolioPreview,

    /// isGuestView
    @Default(false)
    @JsonKey(name: ClientProProfileResponse.isGuestViewKey_)
    bool isGuestView,
  }) = _ClientProProfileResponse;

  factory ClientProProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientProProfileResponseFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String displayNameKey_ = r'display_name';

  static const String headlineKey_ = r'headline';

  static const String coverMediaAssetIdKey_ = r'cover_media_asset_id';

  static const String coverUrlKey_ = r'cover_url';

  static const String bioKey_ = r'bio';

  static const String cityKey_ = r'city';

  static const String countryKey_ = r'country';

  static const String stylesKey_ = r'styles';

  static const String avgRatingKey_ = r'avg_rating';

  static const String reviewCountKey_ = r'review_count';

  static const String portfolioPhotoCountKey_ = r'portfolio_photo_count';

  static const String portfolioVideoCountKey_ = r'portfolio_video_count';

  static const String packagesKey_ = r'packages';

  static const String portfolioPreviewAssetIdsKey_ =
      r'portfolio_preview_asset_ids';

  static const String portfolioPreviewKey_ = r'portfolio_preview';

  static const String isGuestViewKey_ = r'is_guest_view';
}
