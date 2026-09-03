/// ProCard
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
///         "styles": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Styles"
///         },
///         "min_price": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Min Price"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "portfolio_photo_count": {
///             "type": "integer",
///             "title": "Portfolio Photo Count"
///         },
///         "portfolio_video_count": {
///             "type": "integer",
///             "title": "Portfolio Video Count"
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
///         },
///         "primary_niche_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Primary Niche Id"
///         },
///         "top_niches": {
///             "type": "array",
///             "items": {
///                 "type": "object"
///             },
///             "title": "Top Niches"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "currency",
///         "portfolio_photo_count",
///         "portfolio_video_count",
///         "avg_rating",
///         "review_count",
///         "ranking_score"
///     ],
///     "title": "ProCard"
/// }
library pro_card;

import 'exports.dart';
part 'pro_card.freezed.dart';
part 'pro_card.g.dart'; // ProCard

@freezed
abstract class ProCard with _$ProCard {
  const ProCard._();

  @jsonSerializable
  const factory ProCard({
    /// proUserId
    @JsonKey(name: ProCard.proUserIdKey_) required String proUserId,

    /// displayName
    @JsonKey(name: ProCard.displayNameKey_) String? displayName,

    /// city
    @JsonKey(name: ProCard.cityKey_) String? city,

    /// styles
    @JsonKey(name: ProCard.stylesKey_) List<String>? styles,

    /// minPrice
    @JsonKey(name: ProCard.minPriceKey_) String? minPrice,

    /// currency
    @JsonKey(name: ProCard.currencyKey_) required String currency,

    /// portfolioPhotoCount
    @JsonKey(name: ProCard.portfolioPhotoCountKey_)
    required int portfolioPhotoCount,

    /// portfolioVideoCount
    @JsonKey(name: ProCard.portfolioVideoCountKey_)
    required int portfolioVideoCount,

    /// avgRating
    @JsonKey(name: ProCard.avgRatingKey_) required String avgRating,

    /// reviewCount
    @JsonKey(name: ProCard.reviewCountKey_) required int reviewCount,

    /// rankingScore
    @JsonKey(name: ProCard.rankingScoreKey_) required String rankingScore,

    /// primaryNicheId
    @JsonKey(name: ProCard.primaryNicheIdKey_) String? primaryNicheId,

    /// topNiches
    @JsonKey(name: ProCard.topNichesKey_) List<Map<String, dynamic>>? topNiches,
  }) = _ProCard;

  factory ProCard.fromJson(Map<String, dynamic> json) =>
      _$ProCardFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String displayNameKey_ = r'display_name';

  static const String cityKey_ = r'city';

  static const String stylesKey_ = r'styles';

  static const String minPriceKey_ = r'min_price';

  static const String currencyKey_ = r'currency';

  static const String portfolioPhotoCountKey_ = r'portfolio_photo_count';

  static const String portfolioVideoCountKey_ = r'portfolio_video_count';

  static const String avgRatingKey_ = r'avg_rating';

  static const String reviewCountKey_ = r'review_count';

  static const String rankingScoreKey_ = r'ranking_score';

  static const String primaryNicheIdKey_ = r'primary_niche_id';

  static const String topNichesKey_ = r'top_niches';
}
