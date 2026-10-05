/// GearFrameSubmitResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/GearVerificationView"
///             },
///             "title": "Items"
///         },
///         "notes": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Notes"
///         },
///         "floor": {
///             "$ref": "#/components/schemas/GearFloorView"
///         }
///     },
///     "type": "object",
///     "required": [
///         "floor"
///     ],
///     "title": "GearFrameSubmitResponse"
/// }
library gear_frame_submit_response;

import 'exports.dart';
part 'gear_frame_submit_response.freezed.dart';
part 'gear_frame_submit_response.g.dart'; // GearFrameSubmitResponse

@freezed
abstract class GearFrameSubmitResponse with _$GearFrameSubmitResponse {
  const GearFrameSubmitResponse._();

  @jsonSerializable
  const factory GearFrameSubmitResponse({
    /// items
    @JsonKey(name: GearFrameSubmitResponse.itemsKey_)
    List<GearVerificationView>? items,

    /// notes
    @JsonKey(name: GearFrameSubmitResponse.notesKey_) List<String>? notes,

    /// floor
    @JsonKey(name: GearFrameSubmitResponse.floorKey_)
    required GearFloorView floor,
  }) = _GearFrameSubmitResponse;

  factory GearFrameSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$GearFrameSubmitResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String notesKey_ = r'notes';

  static const String floorKey_ = r'floor';
}
