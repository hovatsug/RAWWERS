/// MediaObjectView
/// {
///     "properties": {
///         "variant": {
///             "type": "string",
///             "title": "Variant"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "width": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Width"
///         },
///         "height": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Height"
///         },
///         "url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Url"
///         }
///     },
///     "type": "object",
///     "required": [
///         "variant",
///         "status"
///     ],
///     "title": "MediaObjectView"
/// }
library media_object_view;

import 'exports.dart';
part 'media_object_view.freezed.dart';
part 'media_object_view.g.dart'; // MediaObjectView

@freezed
abstract class MediaObjectView with _$MediaObjectView {
  const MediaObjectView._();

  @jsonSerializable
  const factory MediaObjectView({
    /// variant
    @JsonKey(name: MediaObjectView.variantKey_) required String variant,

    /// status
    @JsonKey(name: MediaObjectView.statusKey_) required String status,

    /// width
    @JsonKey(name: MediaObjectView.widthKey_) int? width,

    /// height
    @JsonKey(name: MediaObjectView.heightKey_) int? height,

    /// url
    @JsonKey(name: MediaObjectView.urlKey_) String? url,
  }) = _MediaObjectView;

  factory MediaObjectView.fromJson(Map<String, dynamic> json) =>
      _$MediaObjectViewFromJson(json);

  static const String variantKey_ = r'variant';

  static const String statusKey_ = r'status';

  static const String widthKey_ = r'width';

  static const String heightKey_ = r'height';

  static const String urlKey_ = r'url';
}
