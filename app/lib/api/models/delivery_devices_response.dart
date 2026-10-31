/// DeliveryDevicesResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/DeliveryDeviceView"
///             },
///             "title": "Items"
///         },
///         "max_devices": {
///             "type": "integer",
///             "title": "Max Devices"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items",
///         "max_devices"
///     ],
///     "title": "DeliveryDevicesResponse"
/// }
library delivery_devices_response;

import 'exports.dart';
part 'delivery_devices_response.freezed.dart';
part 'delivery_devices_response.g.dart'; // DeliveryDevicesResponse

@freezed
abstract class DeliveryDevicesResponse with _$DeliveryDevicesResponse {
  const DeliveryDevicesResponse._();

  @jsonSerializable
  const factory DeliveryDevicesResponse({
    /// items
    @JsonKey(name: DeliveryDevicesResponse.itemsKey_)
    required List<DeliveryDeviceView> items,

    /// maxDevices
    @JsonKey(name: DeliveryDevicesResponse.maxDevicesKey_)
    required int maxDevices,
  }) = _DeliveryDevicesResponse;

  factory DeliveryDevicesResponse.fromJson(Map<String, dynamic> json) =>
      _$DeliveryDevicesResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String maxDevicesKey_ = r'max_devices';
}
