// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_device_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryDeviceView _$DeliveryDeviceViewFromJson(Map<String, dynamic> json) =>
    _DeliveryDeviceView(
      id: json['id'] as String,
      deviceName: json['device_name'] as String,
      tokenPrefix: json['token_prefix'] as String,
      pluginVersion: json['plugin_version'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
    );

Map<String, dynamic> _$DeliveryDeviceViewToJson(_DeliveryDeviceView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_name': instance.deviceName,
      'token_prefix': instance.tokenPrefix,
      'plugin_version': instance.pluginVersion,
      'created_at': instance.createdAt.toIso8601String(),
      'last_used_at': instance.lastUsedAt.toIso8601String(),
    };
