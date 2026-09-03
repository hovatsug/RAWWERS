// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_package_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPackageCreateRequest _$ProPackageCreateRequestFromJson(
  Map<String, dynamic> json,
) => _ProPackageCreateRequest(
  title: json['title'] as String,
  nicheId: json['niche_id'] as String?,
  nicheSlug: json['niche_slug'] as String?,
  description: json['description'] as String?,
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  price: json['price'],
  currency: json['currency'] as String? ?? 'EUR',
  includedPhotos: (json['included_photos'] as num).toInt(),
  extraPhotoPrice: json['extra_photo_price'],
  proofsSlaDays: (json['proofs_sla_days'] as num?)?.toInt() ?? 3,
  finalsSlaDays: (json['finals_sla_days'] as num?)?.toInt() ?? 7,
  addons: (json['addons'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$ProPackageCreateRequestToJson(
  _ProPackageCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'niche_id': instance.nicheId,
  'niche_slug': instance.nicheSlug,
  'description': instance.description,
  'duration_minutes': instance.durationMinutes,
  'price': instance.price,
  'currency': instance.currency,
  'included_photos': instance.includedPhotos,
  'extra_photo_price': instance.extraPhotoPrice,
  'proofs_sla_days': instance.proofsSlaDays,
  'finals_sla_days': instance.finalsSlaDays,
  'addons': instance.addons,
};
