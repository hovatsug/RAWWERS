// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_niche_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProNicheView _$ProNicheViewFromJson(Map<String, dynamic> json) =>
    _ProNicheView(
      slug: json['slug'] as String,
      name: json['name'] as String,
      declaredLevel: json['declared_level'] == null
          ? null
          : DeclaredLevel.fromJson(json['declared_level'] as String),
      isPrimary: json['is_primary'] as bool,
    );

Map<String, dynamic> _$ProNicheViewToJson(_ProNicheView instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'declared_level': instance.declaredLevel,
      'is_primary': instance.isPrimary,
    };
