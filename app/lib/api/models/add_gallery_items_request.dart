/// AddGalleryItemsRequest
/// {
///     "properties": {
///         "media_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Media Asset Ids"
///         },
///         "sort_order_optional": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Sort Order Optional"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_ids"
///     ],
///     "title": "AddGalleryItemsRequest"
/// }
library add_gallery_items_request;

import 'exports.dart';
part 'add_gallery_items_request.freezed.dart';
part 'add_gallery_items_request.g.dart'; // AddGalleryItemsRequest

@freezed
abstract class AddGalleryItemsRequest with _$AddGalleryItemsRequest {
  const AddGalleryItemsRequest._();

  @jsonSerializable
  const factory AddGalleryItemsRequest({
    /// mediaAssetIds
    @JsonKey(name: AddGalleryItemsRequest.mediaAssetIdsKey_)
    required List<String> mediaAssetIds,

    /// sortOrderOptional
    @JsonKey(name: AddGalleryItemsRequest.sortOrderOptionalKey_)
    int? sortOrderOptional,
  }) = _AddGalleryItemsRequest;

  factory AddGalleryItemsRequest.fromJson(Map<String, dynamic> json) =>
      _$AddGalleryItemsRequestFromJson(json);

  static const String mediaAssetIdsKey_ = r'media_asset_ids';

  static const String sortOrderOptionalKey_ = r'sort_order_optional';
}
