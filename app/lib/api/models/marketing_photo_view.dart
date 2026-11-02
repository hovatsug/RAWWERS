/// MarketingPhotoView
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id"
///     ],
///     "title": "MarketingPhotoView"
/// }
library marketing_photo_view;

import 'exports.dart';
part 'marketing_photo_view.freezed.dart';
part 'marketing_photo_view.g.dart'; // MarketingPhotoView

@freezed
abstract class MarketingPhotoView with _$MarketingPhotoView {
  const MarketingPhotoView._();

  @jsonSerializable
  const factory MarketingPhotoView({
    /// mediaAssetId
    @JsonKey(name: MarketingPhotoView.mediaAssetIdKey_)
    required String mediaAssetId,

    /// thumbnailUrl
    @JsonKey(name: MarketingPhotoView.thumbnailUrlKey_) String? thumbnailUrl,
  }) = _MarketingPhotoView;

  factory MarketingPhotoView.fromJson(Map<String, dynamic> json) =>
      _$MarketingPhotoViewFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String thumbnailUrlKey_ = r'thumbnail_url';
}
