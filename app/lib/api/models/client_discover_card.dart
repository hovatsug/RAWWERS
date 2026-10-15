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
///         "min_entry_rate": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Min Entry Rate"
///         },
///         "min_entry_photos": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Min Entry Photos"
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
///         "response_label": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Response Label"
///         },
///         "online": {
///             "type": "boolean",
///             "default": false,
///             "title": "Online"
///         },
///         "ready_in_minutes": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Ready In Minutes"
///         },
///         "answer_within_minutes": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Answer Within Minutes"
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

    /// coverUrl
    @JsonKey(name: ClientDiscoverCard.coverUrlKey_) String? coverUrl,

    /// city
    @JsonKey(name: ClientDiscoverCard.cityKey_) String? city,

    /// country
    @JsonKey(name: ClientDiscoverCard.countryKey_) String? country,

    /// minPrice
    @JsonKey(name: ClientDiscoverCard.minPriceKey_) String? minPrice,

    /// maxPrice
    @JsonKey(name: ClientDiscoverCard.maxPriceKey_) String? maxPrice,

    /// minEntryRate
    @JsonKey(name: ClientDiscoverCard.minEntryRateKey_) String? minEntryRate,

    /// minEntryPhotos
    @JsonKey(name: ClientDiscoverCard.minEntryPhotosKey_) int? minEntryPhotos,

    /// currency
    @JsonKey(name: ClientDiscoverCard.currencyKey_) required String currency,

    /// avgRating
    @JsonKey(name: ClientDiscoverCard.avgRatingKey_) required String avgRating,

    /// reviewCount
    @JsonKey(name: ClientDiscoverCard.reviewCountKey_) required int reviewCount,

    /// responseLabel
    @JsonKey(name: ClientDiscoverCard.responseLabelKey_) String? responseLabel,

    /// online
    @Default(false) @JsonKey(name: ClientDiscoverCard.onlineKey_) bool online,

    /// readyInMinutes
    @JsonKey(name: ClientDiscoverCard.readyInMinutesKey_) int? readyInMinutes,

    /// answerWithinMinutes
    @JsonKey(name: ClientDiscoverCard.answerWithinMinutesKey_)
    int? answerWithinMinutes,

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

  static const String coverUrlKey_ = r'cover_url';

  static const String cityKey_ = r'city';

  static const String countryKey_ = r'country';

  static const String minPriceKey_ = r'min_price';

  static const String maxPriceKey_ = r'max_price';

  static const String minEntryRateKey_ = r'min_entry_rate';

  static const String minEntryPhotosKey_ = r'min_entry_photos';

  static const String currencyKey_ = r'currency';

  static const String avgRatingKey_ = r'avg_rating';

  static const String reviewCountKey_ = r'review_count';

  static const String responseLabelKey_ = r'response_label';

  static const String onlineKey_ = r'online';

  static const String readyInMinutesKey_ = r'ready_in_minutes';

  static const String answerWithinMinutesKey_ = r'answer_within_minutes';

  static const String topNichesKey_ = r'top_niches';

  static const String portfolioPhotoCountKey_ = r'portfolio_photo_count';

  static const String portfolioVideoCountKey_ = r'portfolio_video_count';
}
