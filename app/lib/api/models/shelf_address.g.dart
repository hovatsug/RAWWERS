// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfAddress _$ShelfAddressFromJson(Map<String, dynamic> json) =>
    _ShelfAddress(
      name: json['name'] as String?,
      line1: json['line1'] as String?,
      line2: json['line2'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ShelfAddressToJson(_ShelfAddress instance) =>
    <String, dynamic>{
      'name': instance.name,
      'line1': instance.line1,
      'line2': instance.line2,
      'city': instance.city,
      'region': instance.region,
      'postal_code': instance.postalCode,
      'country': instance.country,
      'phone': instance.phone,
    };
