// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_item_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GearItemCreateRequest _$GearItemCreateRequestFromJson(
  Map<String, dynamic> json,
) => _GearItemCreateRequest(
  category: GearCategory.fromJson(json['category'] as String),
  brand: json['brand'] as String?,
  model: json['model'] as String?,
  serialNumber: json['serial_number'] as String?,
  purchaseDate: json['purchase_date'] == null
      ? null
      : DateTime.parse(json['purchase_date'] as String),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$GearItemCreateRequestToJson(
  _GearItemCreateRequest instance,
) => <String, dynamic>{
  'category': instance.category,
  'brand': instance.brand,
  'model': instance.model,
  'serial_number': instance.serialNumber,
  'purchase_date': instance.purchaseDate?.toIso8601String(),
  'notes': instance.notes,
  'metadata': instance.metadata,
};
