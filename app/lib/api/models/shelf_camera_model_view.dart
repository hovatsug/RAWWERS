/// ShelfCameraModelView
/// {
///     "properties": {
///         "normalised_model": {
///             "type": "string",
///             "title": "Normalised Model"
///         },
///         "make": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Make"
///         },
///         "display_name": {
///             "type": "string",
///             "title": "Display Name"
///         }
///     },
///     "type": "object",
///     "required": [
///         "normalised_model",
///         "display_name"
///     ],
///     "title": "ShelfCameraModelView"
/// }
library shelf_camera_model_view;

import 'exports.dart';
part 'shelf_camera_model_view.freezed.dart';
part 'shelf_camera_model_view.g.dart'; // ShelfCameraModelView

@freezed
abstract class ShelfCameraModelView with _$ShelfCameraModelView {
  const ShelfCameraModelView._();

  @jsonSerializable
  const factory ShelfCameraModelView({
    /// normalisedModel
    @JsonKey(name: ShelfCameraModelView.normalisedModelKey_)
    required String normalisedModel,

    /// make
    @JsonKey(name: ShelfCameraModelView.makeKey_) String? make,

    /// displayName
    @JsonKey(name: ShelfCameraModelView.displayNameKey_)
    required String displayName,
  }) = _ShelfCameraModelView;

  factory ShelfCameraModelView.fromJson(Map<String, dynamic> json) =>
      _$ShelfCameraModelViewFromJson(json);

  static const String normalisedModelKey_ = r'normalised_model';

  static const String makeKey_ = r'make';

  static const String displayNameKey_ = r'display_name';
}
