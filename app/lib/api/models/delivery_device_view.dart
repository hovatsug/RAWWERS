/// DeliveryDeviceView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "device_name": {
///             "type": "string",
///             "title": "Device Name"
///         },
///         "token_prefix": {
///             "type": "string",
///             "title": "Token Prefix"
///         },
///         "plugin_version": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Plugin Version"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "last_used_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Last Used At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "device_name",
///         "token_prefix",
///         "created_at",
///         "last_used_at"
///     ],
///     "title": "DeliveryDeviceView"
/// }
library delivery_device_view;

import 'exports.dart';
part 'delivery_device_view.freezed.dart';
part 'delivery_device_view.g.dart'; // DeliveryDeviceView

@freezed
abstract class DeliveryDeviceView with _$DeliveryDeviceView {
  const DeliveryDeviceView._();

  @jsonSerializable
  const factory DeliveryDeviceView({
    /// id
    @JsonKey(name: DeliveryDeviceView.idKey_) required String id,

    /// deviceName
    @JsonKey(name: DeliveryDeviceView.deviceNameKey_)
    required String deviceName,

    /// tokenPrefix
    @JsonKey(name: DeliveryDeviceView.tokenPrefixKey_)
    required String tokenPrefix,

    /// pluginVersion
    @JsonKey(name: DeliveryDeviceView.pluginVersionKey_) String? pluginVersion,

    /// createdAt
    @JsonKey(name: DeliveryDeviceView.createdAtKey_)
    required DateTime createdAt,

    /// lastUsedAt
    @JsonKey(name: DeliveryDeviceView.lastUsedAtKey_)
    required DateTime lastUsedAt,
  }) = _DeliveryDeviceView;

  factory DeliveryDeviceView.fromJson(Map<String, dynamic> json) =>
      _$DeliveryDeviceViewFromJson(json);

  static const String idKey_ = r'id';

  static const String deviceNameKey_ = r'device_name';

  static const String tokenPrefixKey_ = r'token_prefix';

  static const String pluginVersionKey_ = r'plugin_version';

  static const String createdAtKey_ = r'created_at';

  static const String lastUsedAtKey_ = r'last_used_at';
}
