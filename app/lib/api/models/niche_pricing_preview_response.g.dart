// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'niche_pricing_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NichePricingPreviewResponse _$NichePricingPreviewResponseFromJson(
  Map<String, dynamic> json,
) => _NichePricingPreviewResponse(
  proUserId: json['pro_user_id'] as String,
  nicheId: json['niche_id'] as String,
  packages: (json['packages'] as List<dynamic>)
      .map((e) => PackagePricingPreview.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NichePricingPreviewResponseToJson(
  _NichePricingPreviewResponse instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'niche_id': instance.nicheId,
  'packages': instance.packages,
};
