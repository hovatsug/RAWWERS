/// GalleryItemView
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "sort_order": {
///             "type": "integer",
///             "title": "Sort Order"
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
///         "media_asset_id",
///         "sort_order"
///     ],
///     "title": "GalleryItemView"
/// }
library gallery_item_view;

import 'exports.dart';
part 'gallery_item_view.freezed.dart';
part 'gallery_item_view.g.dart'; // GalleryItemView

@freezed
abstract class GalleryItemView with _$GalleryItemView {
  const GalleryItemView._();

  @jsonSerializable
  const factory GalleryItemView({
    /// mediaAssetId
    @JsonKey(name: GalleryItemView.mediaAssetIdKey_)
    required String mediaAssetId,

    /// sortOrder
    @JsonKey(name: GalleryItemView.sortOrderKey_) required int sortOrder,

    /// thumbnailUrl
    @JsonKey(name: GalleryItemView.thumbnailUrlKey_) String? thumbnailUrl,

    /// watermarkPreviewUrl
    @JsonKey(name: GalleryItemView.watermarkPreviewUrlKey_)
    String? watermarkPreviewUrl,
  }) = _GalleryItemView;

  factory GalleryItemView.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemViewFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String sortOrderKey_ = r'sort_order';

  static const String thumbnailUrlKey_ = r'thumbnail_url';

  static const String watermarkPreviewUrlKey_ = r'watermark_preview_url';
}
