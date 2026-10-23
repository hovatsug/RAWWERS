// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_home_niche.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientHomeNiche _$ClientHomeNicheFromJson(Map<String, dynamic> json) =>
    _ClientHomeNiche(
      slug: json['slug'] as String,
      name: json['name'] as String,
      banner: json['banner'] == null
          ? null
          : NicheBannerView.fromJson(json['banner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClientHomeNicheToJson(_ClientHomeNiche instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'banner': instance.banner,
    };
