// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_pro_package_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicProPackageView _$PublicProPackageViewFromJson(
  Map<String, dynamic> json,
) => _PublicProPackageView(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  price: json['price'] as String,
  currency: json['currency'] as String,
  includedPhotos: (json['included_photos'] as num).toInt(),
  extraPhotoPrice: json['extra_photo_price'] as String,
  proofsSlaDays: (json['proofs_sla_days'] as num).toInt(),
  finalsSlaDays: (json['finals_sla_days'] as num).toInt(),
  addons: (json['addons'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$PublicProPackageViewToJson(
  _PublicProPackageView instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
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
