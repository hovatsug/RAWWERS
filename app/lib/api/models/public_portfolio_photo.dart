/// PublicPortfolioPhoto
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
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
///         "watermark_preview_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Watermark Preview Url"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id"
///     ],
///     "title": "PublicPortfolioPhoto"
/// }
library public_portfolio_photo;

import 'exports.dart';
part 'public_portfolio_photo.freezed.dart';
part 'public_portfolio_photo.g.dart'; // PublicPortfolioPhoto

@freezed
abstract class PublicPortfolioPhoto with _$PublicPortfolioPhoto {
  const PublicPortfolioPhoto._();

  @jsonSerializable
  const factory PublicPortfolioPhoto({
    /// mediaAssetId
    @JsonKey(name: PublicPortfolioPhoto.mediaAssetIdKey_)
    required String mediaAssetId,

    /// thumbnailUrl
    @JsonKey(name: PublicPortfolioPhoto.thumbnailUrlKey_) String? thumbnailUrl,

    /// watermarkPreviewUrl
    @JsonKey(name: PublicPortfolioPhoto.watermarkPreviewUrlKey_)
    String? watermarkPreviewUrl,
  }) = _PublicPortfolioPhoto;

  factory PublicPortfolioPhoto.fromJson(Map<String, dynamic> json) =>
      _$PublicPortfolioPhotoFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String thumbnailUrlKey_ = r'thumbnail_url';

  static const String watermarkPreviewUrlKey_ = r'watermark_preview_url';
}
