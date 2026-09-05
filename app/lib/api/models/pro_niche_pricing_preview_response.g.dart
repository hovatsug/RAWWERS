// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_niche_pricing_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProNichePricingPreviewResponse _$ProNichePricingPreviewResponseFromJson(
  Map<String, dynamic> json,
) => _ProNichePricingPreviewResponse(
  nicheId: json['niche_id'] as String,
  nicheSlug: json['niche_slug'] as String,
  nicheName: json['niche_name'] as String,
  tier: json['tier'] as String,
  entryPrice: json['entry_price'] as String,
  currency: json['currency'] as String,
  entryPriceMin: json['entry_price_min'] as String,
  entryPriceMax: json['entry_price_max'] as String?,
  withinCap: json['within_cap'] as bool,
  curve: (json['curve'] as List<dynamic>?)
      ?.map((e) => ProPricingCurvePoint.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProNichePricingPreviewResponseToJson(
  _ProNichePricingPreviewResponse instance,
) => <String, dynamic>{
  'niche_id': instance.nicheId,
  'niche_slug': instance.nicheSlug,
  'niche_name': instance.nicheName,
  'tier': instance.tier,
  'entry_price': instance.entryPrice,
  'currency': instance.currency,
  'entry_price_min': instance.entryPriceMin,
  'entry_price_max': instance.entryPriceMax,
  'within_cap': instance.withinCap,
  'curve': instance.curve,
};
