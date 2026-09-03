// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_niche_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProNicheInput _$ProNicheInputFromJson(Map<String, dynamic> json) =>
    _ProNicheInput(
      slug: json['slug'] as String,
      declaredLevel: json['declared_level'] == null
          ? null
          : DeclaredLevel.fromJson(json['declared_level'] as String),
      isPrimary: json['is_primary'] as bool? ?? false,
    );

Map<String, dynamic> _$ProNicheInputToJson(_ProNicheInput instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'declared_level': instance.declaredLevel,
      'is_primary': instance.isPrimary,
    };
