// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_extra_image_price_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProExtraImagePriceRow _$ProExtraImagePriceRowFromJson(
  Map<String, dynamic> json,
) => _ProExtraImagePriceRow(
  nicheSlug: json['niche_slug'] as String,
  nicheName: json['niche_name'] as String,
  configuredUnitPrice: json['configured_unit_price'] as String,
  appliedUnitPrice: json['applied_unit_price'] as String,
  policyMin: json['policy_min'] as String,
  policyMax: json['policy_max'] as String?,
  currency: json['currency'] as String,
);

Map<String, dynamic> _$ProExtraImagePriceRowToJson(
  _ProExtraImagePriceRow instance,
) => <String, dynamic>{
  'niche_slug': instance.nicheSlug,
  'niche_name': instance.nicheName,
  'configured_unit_price': instance.configuredUnitPrice,
  'applied_unit_price': instance.appliedUnitPrice,
  'policy_min': instance.policyMin,
  'policy_max': instance.policyMax,
  'currency': instance.currency,
};
