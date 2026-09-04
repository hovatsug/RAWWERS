/// ClientPortfolioItem
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "kind"
///     ],
///     "title": "ClientPortfolioItem"
/// }
library client_portfolio_item;

import 'exports.dart';
part 'client_portfolio_item.freezed.dart';
part 'client_portfolio_item.g.dart'; // ClientPortfolioItem

@freezed
abstract class ClientPortfolioItem with _$ClientPortfolioItem {
  const ClientPortfolioItem._();

  @jsonSerializable
  const factory ClientPortfolioItem({
    /// mediaAssetId
    @JsonKey(name: ClientPortfolioItem.mediaAssetIdKey_)
    required String mediaAssetId,

    /// kind
    @JsonKey(name: ClientPortfolioItem.kindKey_) required String kind,

    /// thumbnailUrl
    @JsonKey(name: ClientPortfolioItem.thumbnailUrlKey_) String? thumbnailUrl,
  }) = _ClientPortfolioItem;

  factory ClientPortfolioItem.fromJson(Map<String, dynamic> json) =>
      _$ClientPortfolioItemFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String kindKey_ = r'kind';

  static const String thumbnailUrlKey_ = r'thumbnail_url';
}
