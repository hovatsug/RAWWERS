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
///         },
///         "plugin_download_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Plugin Download Url"
///         },
///         "plugin_latest_version": {
///             "type": "string",
///             "title": "Plugin Latest Version"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items",
///         "max_devices",
///         "plugin_latest_version"
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

    /// pluginDownloadUrl
    @JsonKey(name: DeliveryDevicesResponse.pluginDownloadUrlKey_)
    String? pluginDownloadUrl,

    /// pluginLatestVersion
    @JsonKey(name: DeliveryDevicesResponse.pluginLatestVersionKey_)
    required String pluginLatestVersion,
  }) = _DeliveryDevicesResponse;

  factory DeliveryDevicesResponse.fromJson(Map<String, dynamic> json) =>
      _$DeliveryDevicesResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String maxDevicesKey_ = r'max_devices';

  static const String pluginDownloadUrlKey_ = r'plugin_download_url';

  static const String pluginLatestVersionKey_ = r'plugin_latest_version';
}
