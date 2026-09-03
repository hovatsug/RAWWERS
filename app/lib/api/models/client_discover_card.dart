/// ClientDiscoverCard
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
///         "max_price": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Max Price"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
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
///         "top_niches": {
///             "type": "array",
///             "items": {
///                 "type": "object"
///             },
///             "title": "Top Niches"
///         },
///         "portfolio_photo_count": {
///             "type": "integer",
///             "title": "Portfolio Photo Count"
///         },
///         "portfolio_video_count": {
///             "type": "integer",
///             "title": "Portfolio Video Count"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "currency",
///         "avg_rating",
///         "review_count",
///         "portfolio_photo_count",
///         "portfolio_video_count"
///     ],
///     "title": "ClientDiscoverCard"
/// }
library client_discover_card;

import 'exports.dart';
part 'client_discover_card.freezed.dart';
part 'client_discover_card.g.dart'; // ClientDiscoverCard

@freezed
abstract class ClientDiscoverCard with _$ClientDiscoverCard {
  const ClientDiscoverCard._();

  @jsonSerializable
  const factory ClientDiscoverCard({
    /// proUserId
    @JsonKey(name: ClientDiscoverCard.proUserIdKey_) required String proUserId,

    /// displayName
    @JsonKey(name: ClientDiscoverCard.displayNameKey_) String? displayName,

    /// headline
    @JsonKey(name: ClientDiscoverCard.headlineKey_) String? headline,

    /// coverMediaAssetId
    @JsonKey(name: ClientDiscoverCard.coverMediaAssetIdKey_)
    String? coverMediaAssetId,

    /// city
    @JsonKey(name: ClientDiscoverCard.cityKey_) String? city,

    /// country
    @JsonKey(name: ClientDiscoverCard.countryKey_) String? country,

    /// minPrice
    @JsonKey(name: ClientDiscoverCard.minPriceKey_) String? minPrice,

    /// maxPrice
    @JsonKey(name: ClientDiscoverCard.maxPriceKey_) String? maxPrice,

    /// currency
    @JsonKey(name: ClientDiscoverCard.currencyKey_) required String currency,

    /// avgRating
    @JsonKey(name: ClientDiscoverCard.avgRatingKey_) required String avgRating,

    /// reviewCount
    @JsonKey(name: ClientDiscoverCard.reviewCountKey_) required int reviewCount,

    /// topNiches
    @JsonKey(name: ClientDiscoverCard.topNichesKey_)
    List<Map<String, dynamic>>? topNiches,

    /// portfolioPhotoCount
    @JsonKey(name: ClientDiscoverCard.portfolioPhotoCountKey_)
    required int portfolioPhotoCount,

    /// portfolioVideoCount
    @JsonKey(name: ClientDiscoverCard.portfolioVideoCountKey_)
    required int portfolioVideoCount,
  }) = _ClientDiscoverCard;

  factory ClientDiscoverCard.fromJson(Map<String, dynamic> json) =>
      _$ClientDiscoverCardFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String displayNameKey_ = r'display_name';

  static const String headlineKey_ = r'headline';

  static const String coverMediaAssetIdKey_ = r'cover_media_asset_id';

  static const String cityKey_ = r'city';

  static const String countryKey_ = r'country';

  static const String minPriceKey_ = r'min_price';

  static const String maxPriceKey_ = r'max_price';

  static const String currencyKey_ = r'currency';

  static const String avgRatingKey_ = r'avg_rating';

  static const String reviewCountKey_ = r'review_count';

  static const String topNichesKey_ = r'top_niches';

  static const String portfolioPhotoCountKey_ = r'portfolio_photo_count';

  static const String portfolioVideoCountKey_ = r'portfolio_video_count';
}
