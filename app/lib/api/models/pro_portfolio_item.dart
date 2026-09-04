/// ProPortfolioItem
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "kind": {
///             "type": "string",
///             "title": "Kind"
///         },
///         "thumbnail_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Thumbnail Url"
///         },
///         "niche_slugs": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Niche Slugs"
///         },
///         "is_cover": {
///             "type": "boolean",
///             "default": false,
///             "title": "Is Cover"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "kind",
///         "created_at"
///     ],
///     "title": "ProPortfolioItem"
/// }
library pro_portfolio_item;

import 'exports.dart';
part 'pro_portfolio_item.freezed.dart';
part 'pro_portfolio_item.g.dart'; // ProPortfolioItem

@freezed
abstract class ProPortfolioItem with _$ProPortfolioItem {
  const ProPortfolioItem._();

  @jsonSerializable
  const factory ProPortfolioItem({
    /// mediaAssetId
    @JsonKey(name: ProPortfolioItem.mediaAssetIdKey_)
    required String mediaAssetId,

    /// kind
    @JsonKey(name: ProPortfolioItem.kindKey_) required String kind,

    /// thumbnailUrl
    @JsonKey(name: ProPortfolioItem.thumbnailUrlKey_) String? thumbnailUrl,

    /// nicheSlugs
    @JsonKey(name: ProPortfolioItem.nicheSlugsKey_) List<String>? nicheSlugs,

    /// isCover
    @Default(false) @JsonKey(name: ProPortfolioItem.isCoverKey_) bool isCover,

    /// createdAt
    @JsonKey(name: ProPortfolioItem.createdAtKey_) required DateTime createdAt,
  }) = _ProPortfolioItem;

  factory ProPortfolioItem.fromJson(Map<String, dynamic> json) =>
      _$ProPortfolioItemFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String kindKey_ = r'kind';

  static const String thumbnailUrlKey_ = r'thumbnail_url';

  static const String nicheSlugsKey_ = r'niche_slugs';

  static const String isCoverKey_ = r'is_cover';

  static const String createdAtKey_ = r'created_at';
}
