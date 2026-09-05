// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_package_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPackageView _$ProPackageViewFromJson(Map<String, dynamic> json) =>
    _ProPackageView(
      id: json['id'] as String,
      proUserId: json['pro_user_id'] as String,
      nicheId: json['niche_id'] as String,
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
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$ProPackageViewToJson(_ProPackageView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pro_user_id': instance.proUserId,
      'niche_id': instance.nicheId,
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
      'is_active': instance.isActive,
    };
