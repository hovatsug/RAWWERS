// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_devices_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryDevicesResponse _$DeliveryDevicesResponseFromJson(
  Map<String, dynamic> json,
) => _DeliveryDevicesResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => DeliveryDeviceView.fromJson(e as Map<String, dynamic>))
      .toList(),
  maxDevices: (json['max_devices'] as num).toInt(),
);

Map<String, dynamic> _$DeliveryDevicesResponseToJson(
  _DeliveryDevicesResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'max_devices': instance.maxDevices,
};
