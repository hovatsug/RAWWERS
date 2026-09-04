// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_item_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GearItemView _$GearItemViewFromJson(Map<String, dynamic> json) =>
    _GearItemView(
      id: json['id'] as String,
      proUserId: json['pro_user_id'] as String,
      category: GearCategory.fromJson(json['category'] as String),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      purchaseDate: json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
      notes: json['notes'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$GearItemViewToJson(_GearItemView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pro_user_id': instance.proUserId,
      'category': instance.category,
      'brand': instance.brand,
      'model': instance.model,
      'serial_number': instance.serialNumber,
      'purchase_date': instance.purchaseDate?.toIso8601String(),
      'notes': instance.notes,
      'meta': instance.meta,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
