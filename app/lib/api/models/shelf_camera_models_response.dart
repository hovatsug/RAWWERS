/// ShelfCameraModelsResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ShelfCameraModelView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items"
///     ],
///     "title": "ShelfCameraModelsResponse"
/// }
library shelf_camera_models_response;

import 'exports.dart';
part 'shelf_camera_models_response.freezed.dart';
part 'shelf_camera_models_response.g.dart'; // ShelfCameraModelsResponse

@freezed
abstract class ShelfCameraModelsResponse with _$ShelfCameraModelsResponse {
  const ShelfCameraModelsResponse._();

  @jsonSerializable
  const factory ShelfCameraModelsResponse({
    /// items
    @JsonKey(name: ShelfCameraModelsResponse.itemsKey_)
    required List<ShelfCameraModelView> items,
  }) = _ShelfCameraModelsResponse;

  factory ShelfCameraModelsResponse.fromJson(Map<String, dynamic> json) =>
      _$ShelfCameraModelsResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
