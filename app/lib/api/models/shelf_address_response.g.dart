// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfAddressResponse _$ShelfAddressResponseFromJson(
  Map<String, dynamic> json,
) => _ShelfAddressResponse(
  address: json['address'] == null
      ? null
      : ShelfAddress.fromJson(json['address'] as Map<String, dynamic>),
  allowedCountries: (json['allowed_countries'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ShelfAddressResponseToJson(
  _ShelfAddressResponse instance,
) => <String, dynamic>{
  'address': instance.address,
  'allowed_countries': instance.allowedCountries,
};
