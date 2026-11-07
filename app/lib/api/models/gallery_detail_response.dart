/// GalleryDetailResponse
/// {
///     "properties": {
///         "gallery": {
///             "$ref": "#/components/schemas/ProofGalleryResponse"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/GalleryItemView"
///             },
///             "title": "Items"
///         },
///         "addon_window_ends_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Addon Window Ends At"
///         },
///         "addon_open": {
///             "type": "boolean",
///             "default": false,
///             "title": "Addon Open"
///         },
///         "chosen_media_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Chosen Media Asset Ids"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gallery",
///         "items"
///     ],
///     "title": "GalleryDetailResponse"
/// }
library gallery_detail_response;

import 'exports.dart';
part 'gallery_detail_response.freezed.dart';
part 'gallery_detail_response.g.dart'; // GalleryDetailResponse

@freezed
abstract class GalleryDetailResponse with _$GalleryDetailResponse {
  const GalleryDetailResponse._();

  @jsonSerializable
  const factory GalleryDetailResponse({
    /// gallery
    @JsonKey(name: GalleryDetailResponse.galleryKey_)
    required ProofGalleryResponse gallery,

    /// items
    @JsonKey(name: GalleryDetailResponse.itemsKey_)
    required List<GalleryItemView> items,

    /// addonWindowEndsAt
    @JsonKey(name: GalleryDetailResponse.addonWindowEndsAtKey_)
    DateTime? addonWindowEndsAt,

    /// addonOpen
    @Default(false)
    @JsonKey(name: GalleryDetailResponse.addonOpenKey_)
    bool addonOpen,

    /// chosenMediaAssetIds
    @JsonKey(name: GalleryDetailResponse.chosenMediaAssetIdsKey_)
    List<String>? chosenMediaAssetIds,
  }) = _GalleryDetailResponse;

  factory GalleryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GalleryDetailResponseFromJson(json);

  static const String galleryKey_ = r'gallery';

  static const String itemsKey_ = r'items';

  static const String addonWindowEndsAtKey_ = r'addon_window_ends_at';

  static const String addonOpenKey_ = r'addon_open';

  static const String chosenMediaAssetIdsKey_ = r'chosen_media_asset_ids';
}
