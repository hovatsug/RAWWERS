/// ProPublicProfileResponse
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
///         "packages": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/PublicProPackageView"
///             },
///             "title": "Packages"
///         },
///         "portfolio_photos": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/PublicPortfolioPhoto"
///             },
///             "title": "Portfolio Photos"
///         },
///         "portfolio_videos": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/PublicPortfolioVideo"
///             },
///             "title": "Portfolio Videos"
///         },
///         "gigs_completed": {
///             "type": "integer",
///             "title": "Gigs Completed"
///         },
///         "gigs_cancelled": {
///             "type": "integer",
///             "title": "Gigs Cancelled"
///         },
///         "disputes_count": {
///             "type": "integer",
///             "title": "Disputes Count"
///         },
///         "avg_response_minutes": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Avg Response Minutes"
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
///         "ranking_score": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Ranking Score"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "packages",
///         "portfolio_photos",
///         "portfolio_videos",
///         "gigs_completed",
///         "gigs_cancelled",
///         "disputes_count",
///         "avg_rating",
///         "review_count",
///         "ranking_score"
///     ],
///     "title": "ProPublicProfileResponse"
/// }
library pro_public_profile_response;

import 'exports.dart';
part 'pro_public_profile_response.freezed.dart';
part 'pro_public_profile_response.g.dart'; // ProPublicProfileResponse

@freezed
abstract class ProPublicProfileResponse with _$ProPublicProfileResponse {
  const ProPublicProfileResponse._();

  @jsonSerializable
  const factory ProPublicProfileResponse({
    /// proUserId
    @JsonKey(name: ProPublicProfileResponse.proUserIdKey_)
    required String proUserId,

    /// displayName
    @JsonKey(name: ProPublicProfileResponse.displayNameKey_)
    String? displayName,

    /// headline
    @JsonKey(name: ProPublicProfileResponse.headlineKey_) String? headline,

    /// coverMediaAssetId
    @JsonKey(name: ProPublicProfileResponse.coverMediaAssetIdKey_)
    String? coverMediaAssetId,

    /// bio
    @JsonKey(name: ProPublicProfileResponse.bioKey_) String? bio,

    /// city
    @JsonKey(name: ProPublicProfileResponse.cityKey_) String? city,

    /// country
    @JsonKey(name: ProPublicProfileResponse.countryKey_) String? country,

    /// styles
    @JsonKey(name: ProPublicProfileResponse.stylesKey_) List<String>? styles,

    /// packages
    @JsonKey(name: ProPublicProfileResponse.packagesKey_)
    required List<PublicProPackageView> packages,

    /// portfolioPhotos
    @JsonKey(name: ProPublicProfileResponse.portfolioPhotosKey_)
    required List<PublicPortfolioPhoto> portfolioPhotos,

    /// portfolioVideos
    @JsonKey(name: ProPublicProfileResponse.portfolioVideosKey_)
    required List<PublicPortfolioVideo> portfolioVideos,

    /// gigsCompleted
    @JsonKey(name: ProPublicProfileResponse.gigsCompletedKey_)
    required int gigsCompleted,

    /// gigsCancelled
    @JsonKey(name: ProPublicProfileResponse.gigsCancelledKey_)
    required int gigsCancelled,

    /// disputesCount
    @JsonKey(name: ProPublicProfileResponse.disputesCountKey_)
    required int disputesCount,

    /// avgResponseMinutes
    @JsonKey(name: ProPublicProfileResponse.avgResponseMinutesKey_)
    int? avgResponseMinutes,

    /// avgRating
    @JsonKey(name: ProPublicProfileResponse.avgRatingKey_)
    required String avgRating,

    /// reviewCount
    @JsonKey(name: ProPublicProfileResponse.reviewCountKey_)
    required int reviewCount,

    /// rankingScore
    @JsonKey(name: ProPublicProfileResponse.rankingScoreKey_)
    required String rankingScore,
  }) = _ProPublicProfileResponse;

  factory ProPublicProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProPublicProfileResponseFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String displayNameKey_ = r'display_name';

  static const String headlineKey_ = r'headline';

  static const String coverMediaAssetIdKey_ = r'cover_media_asset_id';

  static const String bioKey_ = r'bio';

  static const String cityKey_ = r'city';

  static const String countryKey_ = r'country';

  static const String stylesKey_ = r'styles';

  static const String packagesKey_ = r'packages';

  static const String portfolioPhotosKey_ = r'portfolio_photos';

  static const String portfolioVideosKey_ = r'portfolio_videos';

  static const String gigsCompletedKey_ = r'gigs_completed';

  static const String gigsCancelledKey_ = r'gigs_cancelled';

  static const String disputesCountKey_ = r'disputes_count';

  static const String avgResponseMinutesKey_ = r'avg_response_minutes';

  static const String avgRatingKey_ = r'avg_rating';

  static const String reviewCountKey_ = r'review_count';

  static const String rankingScoreKey_ = r'ranking_score';
}
