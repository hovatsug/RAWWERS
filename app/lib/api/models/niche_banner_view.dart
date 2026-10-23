/// NicheBannerView
/// {
///     "properties": {
///         "style": {
///             "$ref": "#/components/schemas/NicheBannerStyle"
///         },
///         "name": {
///             "type": "string",
///             "title": "Name"
///         },
///         "tagline": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Tagline"
///         },
///         "image": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/NicheBannerImageView"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         }
///     },
///     "type": "object",
///     "required": [
///         "style",
///         "name"
///     ],
///     "title": "NicheBannerView",
///     "description": "A niche's banner as every screen draws it.\n\n`style` \"text\" is a deliberate typographic banner - name and tagline, no\nimage, and none is sent. \"image\" with no `image` is a niche whose image\nhas not been uploaded: the app draws the neutral ground."
/// }
library niche_banner_view;

import 'exports.dart';
part 'niche_banner_view.freezed.dart';
part 'niche_banner_view.g.dart'; // NicheBannerView

@freezed
abstract class NicheBannerView with _$NicheBannerView {
  const NicheBannerView._();

  @jsonSerializable
  const factory NicheBannerView({
    /// style
    @JsonKey(name: NicheBannerView.styleKey_) required NicheBannerStyle style,

    /// name
    @JsonKey(name: NicheBannerView.nameKey_) required String name,

    /// tagline
    @JsonKey(name: NicheBannerView.taglineKey_) String? tagline,

    /// image
    @JsonKey(name: NicheBannerView.imageKey_) NicheBannerImageView? image,
  }) = _NicheBannerView;

  factory NicheBannerView.fromJson(Map<String, dynamic> json) =>
      _$NicheBannerViewFromJson(json);

  static const String styleKey_ = r'style';

  static const String nameKey_ = r'name';

  static const String taglineKey_ = r'tagline';

  static const String imageKey_ = r'image';
}
