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
  }) = _GalleryDetailResponse;

  factory GalleryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GalleryDetailResponseFromJson(json);

  static const String galleryKey_ = r'gallery';

  static const String itemsKey_ = r'items';
}
