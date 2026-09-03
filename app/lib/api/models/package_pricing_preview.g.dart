// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_pricing_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackagePricingPreview _$PackagePricingPreviewFromJson(
  Map<String, dynamic> json,
) => _PackagePricingPreview(
  packageId: json['package_id'] as String,
  title: json['title'] as String,
  entryPrice: json['entry_price'] as String,
  currency: json['currency'] as String,
  priceAtPhotoCount: json['price_at_photo_count'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PackagePricingPreviewToJson(
  _PackagePricingPreview instance,
) => <String, dynamic>{
  'package_id': instance.packageId,
  'title': instance.title,
  'entry_price': instance.entryPrice,
  'currency': instance.currency,
  'price_at_photo_count': instance.priceAtPhotoCount,
};
