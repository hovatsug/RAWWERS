// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_pricing_curve_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPricingCurvePoint _$ProPricingCurvePointFromJson(
  Map<String, dynamic> json,
) => _ProPricingCurvePoint(
  photoCount: (json['photo_count'] as num).toInt(),
  total: json['total'] as String,
  perPhoto: json['per_photo'] as String,
);

Map<String, dynamic> _$ProPricingCurvePointToJson(
  _ProPricingCurvePoint instance,
) => <String, dynamic>{
  'photo_count': instance.photoCount,
  'total': instance.total,
  'per_photo': instance.perPhoto,
};
