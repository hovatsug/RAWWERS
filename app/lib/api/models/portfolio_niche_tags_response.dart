/// PortfolioNicheTagsResponse
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "niche_slugs": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Niche Slugs"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id"
///     ],
///     "title": "PortfolioNicheTagsResponse"
/// }
library portfolio_niche_tags_response;

import 'exports.dart';
part 'portfolio_niche_tags_response.freezed.dart';
part 'portfolio_niche_tags_response.g.dart'; // PortfolioNicheTagsResponse

@freezed
abstract class PortfolioNicheTagsResponse with _$PortfolioNicheTagsResponse {
  const PortfolioNicheTagsResponse._();

  @jsonSerializable
  const factory PortfolioNicheTagsResponse({
    /// mediaAssetId
    @JsonKey(name: PortfolioNicheTagsResponse.mediaAssetIdKey_)
    required String mediaAssetId,

    /// nicheSlugs
    @JsonKey(name: PortfolioNicheTagsResponse.nicheSlugsKey_)
    List<String>? nicheSlugs,
  }) = _PortfolioNicheTagsResponse;

  factory PortfolioNicheTagsResponse.fromJson(Map<String, dynamic> json) =>
      _$PortfolioNicheTagsResponseFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String nicheSlugsKey_ = r'niche_slugs';
}
