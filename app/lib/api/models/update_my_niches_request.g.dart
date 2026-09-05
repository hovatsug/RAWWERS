// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_my_niches_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateMyNichesRequest _$UpdateMyNichesRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateMyNichesRequest(
  primaryNicheSlug: json['primary_niche_slug'] as String?,
  niches: (json['niches'] as List<dynamic>?)
      ?.map((e) => ProNicheInput.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpdateMyNichesRequestToJson(
  _UpdateMyNichesRequest instance,
) => <String, dynamic>{
  'primary_niche_slug': instance.primaryNicheSlug,
  'niches': instance.niches,
};
