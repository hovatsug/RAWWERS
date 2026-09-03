// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_package_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPackageUpdateRequest _$ProPackageUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ProPackageUpdateRequest(
  title: json['title'] as String?,
  nicheId: json['niche_id'] as String?,
  nicheSlug: json['niche_slug'] as String?,
  description: json['description'] as String?,
  durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
  price: json['price'],
  currency: json['currency'] as String?,
  includedPhotos: (json['included_photos'] as num?)?.toInt(),
  extraPhotoPrice: json['extra_photo_price'],
  proofsSlaDays: (json['proofs_sla_days'] as num?)?.toInt(),
  finalsSlaDays: (json['finals_sla_days'] as num?)?.toInt(),
  addons: (json['addons'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$ProPackageUpdateRequestToJson(
  _ProPackageUpdateRequest instance,
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
  'is_active': instance.isActive,
};
