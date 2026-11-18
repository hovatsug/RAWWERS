/// ProPortfolioResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ProPortfolioItem"
///             },
///             "title": "Items"
///         },
///         "photo_count": {
///             "type": "integer",
///             "title": "Photo Count"
///         },
///         "video_count": {
///             "type": "integer",
///             "title": "Video Count"
///         },
///         "photo_minimum": {
///             "type": "integer",
///             "title": "Photo Minimum"
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
///         "cover_chosen": {
///             "type": "boolean",
///             "default": false,
///             "title": "Cover Chosen"
///         }
///     },
///     "type": "object",
///     "required": [
///         "photo_count",
///         "video_count",
///         "photo_minimum"
///     ],
///     "title": "ProPortfolioResponse"
/// }
library pro_portfolio_response;

import 'exports.dart';
part 'pro_portfolio_response.freezed.dart';
part 'pro_portfolio_response.g.dart'; // ProPortfolioResponse

@freezed
abstract class ProPortfolioResponse with _$ProPortfolioResponse {
  const ProPortfolioResponse._();

  @jsonSerializable
  const factory ProPortfolioResponse({
    /// items
    @JsonKey(name: ProPortfolioResponse.itemsKey_)
    List<ProPortfolioItem>? items,

    /// photoCount
    @JsonKey(name: ProPortfolioResponse.photoCountKey_) required int photoCount,

    /// videoCount
    @JsonKey(name: ProPortfolioResponse.videoCountKey_) required int videoCount,

    /// photoMinimum
    @JsonKey(name: ProPortfolioResponse.photoMinimumKey_)
    required int photoMinimum,

    /// coverMediaAssetId
    @JsonKey(name: ProPortfolioResponse.coverMediaAssetIdKey_)
    String? coverMediaAssetId,

    /// coverChosen
    @Default(false)
    @JsonKey(name: ProPortfolioResponse.coverChosenKey_)
    bool coverChosen,
  }) = _ProPortfolioResponse;

  factory ProPortfolioResponse.fromJson(Map<String, dynamic> json) =>
      _$ProPortfolioResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String photoCountKey_ = r'photo_count';

  static const String videoCountKey_ = r'video_count';

  static const String photoMinimumKey_ = r'photo_minimum';

  static const String coverMediaAssetIdKey_ = r'cover_media_asset_id';

  static const String coverChosenKey_ = r'cover_chosen';
}
