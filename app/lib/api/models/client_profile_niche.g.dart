// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_profile_niche.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientProfileNiche _$ClientProfileNicheFromJson(Map<String, dynamic> json) =>
    _ClientProfileNiche(
      slug: json['slug'] as String,
      name: json['name'] as String,
      tier: SkillTier.fromJson(json['tier'] as String),
      photoCount: (json['photo_count'] as num).toInt(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ClientProfileNicheToJson(_ClientProfileNiche instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'tier': instance.tier,
      'photo_count': instance.photoCount,
      'description': instance.description,
    };
