// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_my_niches_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateMyNichesResponse _$UpdateMyNichesResponseFromJson(
  Map<String, dynamic> json,
) => _UpdateMyNichesResponse(
  primaryNicheSlug: json['primary_niche_slug'] as String?,
  niches: (json['niches'] as List<dynamic>?)
      ?.map((e) => ProNicheView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpdateMyNichesResponseToJson(
  _UpdateMyNichesResponse instance,
) => <String, dynamic>{
  'primary_niche_slug': instance.primaryNicheSlug,
  'niches': instance.niches,
};
