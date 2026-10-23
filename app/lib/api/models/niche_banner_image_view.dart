/// NicheBannerImageView
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "tile_url": {
///             "type": "string",
///             "title": "Tile Url"
///         },
///         "hero_url": {
///             "type": "string",
///             "title": "Hero Url"
///         },
///         "placeholder": {
///             "type": "string",
///             "title": "Placeholder"
///         },
///         "alt_text": {
///             "type": "string",
///             "title": "Alt Text"
///         },
///         "focal_x": {
///             "type": "number",
///             "title": "Focal X"
///         },
///         "focal_y": {
///             "type": "number",
///             "title": "Focal Y"
///         },
///         "scrim_opacity": {
///             "type": "number",
///             "title": "Scrim Opacity"
///         },
///         "width": {
///             "type": "integer",
///             "title": "Width"
///         },
///         "height": {
///             "type": "integer",
///             "title": "Height"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "tile_url",
///         "hero_url",
///         "placeholder",
///         "alt_text",
///         "focal_x",
///         "focal_y",
///         "scrim_opacity",
///         "width",
///         "height"
///     ],
///     "title": "NicheBannerImageView"
/// }
library niche_banner_image_view;

import 'exports.dart';
part 'niche_banner_image_view.freezed.dart';
part 'niche_banner_image_view.g.dart'; // NicheBannerImageView

@freezed
abstract class NicheBannerImageView with _$NicheBannerImageView {
  const NicheBannerImageView._();

  @jsonSerializable
  const factory NicheBannerImageView({
    /// mediaAssetId
    @JsonKey(name: NicheBannerImageView.mediaAssetIdKey_)
    required String mediaAssetId,

    /// tileUrl
    @JsonKey(name: NicheBannerImageView.tileUrlKey_) required String tileUrl,

    /// heroUrl
    @JsonKey(name: NicheBannerImageView.heroUrlKey_) required String heroUrl,

    /// placeholder
    @JsonKey(name: NicheBannerImageView.placeholderKey_)
    required String placeholder,

    /// altText
    @JsonKey(name: NicheBannerImageView.altTextKey_) required String altText,

    /// focalX
    @JsonKey(name: NicheBannerImageView.focalXKey_) required double focalX,

    /// focalY
    @JsonKey(name: NicheBannerImageView.focalYKey_) required double focalY,

    /// scrimOpacity
    @JsonKey(name: NicheBannerImageView.scrimOpacityKey_)
    required double scrimOpacity,

    /// width
    @JsonKey(name: NicheBannerImageView.widthKey_) required int width,

    /// height
    @JsonKey(name: NicheBannerImageView.heightKey_) required int height,
  }) = _NicheBannerImageView;

  factory NicheBannerImageView.fromJson(Map<String, dynamic> json) =>
      _$NicheBannerImageViewFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String tileUrlKey_ = r'tile_url';

  static const String heroUrlKey_ = r'hero_url';

  static const String placeholderKey_ = r'placeholder';

  static const String altTextKey_ = r'alt_text';

  static const String focalXKey_ = r'focal_x';

  static const String focalYKey_ = r'focal_y';

  static const String scrimOpacityKey_ = r'scrim_opacity';

  static const String widthKey_ = r'width';

  static const String heightKey_ = r'height';
}
