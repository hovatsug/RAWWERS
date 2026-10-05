/// GearVerificationListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/GearVerificationView"
///             },
///             "title": "Items"
///         },
///         "floor": {
///             "$ref": "#/components/schemas/GearFloorView"
///         }
///     },
///     "type": "object",
///     "required": [
///         "floor"
///     ],
///     "title": "GearVerificationListResponse"
/// }
library gear_verification_list_response;

import 'exports.dart';
part 'gear_verification_list_response.freezed.dart';
part 'gear_verification_list_response.g.dart'; // GearVerificationListResponse

@freezed
abstract class GearVerificationListResponse
    with _$GearVerificationListResponse {
  const GearVerificationListResponse._();

  @jsonSerializable
  const factory GearVerificationListResponse({
    /// items
    @JsonKey(name: GearVerificationListResponse.itemsKey_)
    List<GearVerificationView>? items,

    /// floor
    @JsonKey(name: GearVerificationListResponse.floorKey_)
    required GearFloorView floor,
  }) = _GearVerificationListResponse;

  factory GearVerificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$GearVerificationListResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String floorKey_ = r'floor';
}
