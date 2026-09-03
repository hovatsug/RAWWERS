/// SaveSelectionRequest
/// {
///     "properties": {
///         "media_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Media Asset Ids"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_ids"
///     ],
///     "title": "SaveSelectionRequest"
/// }
library save_selection_request;

import 'exports.dart';
part 'save_selection_request.freezed.dart';
part 'save_selection_request.g.dart'; // SaveSelectionRequest

@freezed
abstract class SaveSelectionRequest with _$SaveSelectionRequest {
  const SaveSelectionRequest._();

  @jsonSerializable
  const factory SaveSelectionRequest({
    /// mediaAssetIds
    @JsonKey(name: SaveSelectionRequest.mediaAssetIdsKey_)
    required List<String> mediaAssetIds,
  }) = _SaveSelectionRequest;

  factory SaveSelectionRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveSelectionRequestFromJson(json);

  static const String mediaAssetIdsKey_ = r'media_asset_ids';
}
