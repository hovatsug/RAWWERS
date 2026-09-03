/// SharedMediaItemView
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "preview_url": {
///             "type": "string",
///             "title": "Preview Url"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "preview_url"
///     ],
///     "title": "SharedMediaItemView"
/// }
library shared_media_item_view;

import 'exports.dart';
part 'shared_media_item_view.freezed.dart';
part 'shared_media_item_view.g.dart'; // SharedMediaItemView

@freezed
abstract class SharedMediaItemView with _$SharedMediaItemView {
  const SharedMediaItemView._();

  @jsonSerializable
  const factory SharedMediaItemView({
    /// mediaAssetId
    @JsonKey(name: SharedMediaItemView.mediaAssetIdKey_)
    required String mediaAssetId,

    /// previewUrl
    @JsonKey(name: SharedMediaItemView.previewUrlKey_)
    required String previewUrl,
  }) = _SharedMediaItemView;

  factory SharedMediaItemView.fromJson(Map<String, dynamic> json) =>
      _$SharedMediaItemViewFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String previewUrlKey_ = r'preview_url';
}
