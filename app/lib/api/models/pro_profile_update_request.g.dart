// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_profile_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProProfileUpdateRequest _$ProProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ProProfileUpdateRequest(
  displayName: json['display_name'] as String?,
  headline: json['headline'] as String?,
  coverMediaAssetId: json['cover_media_asset_id'] as String?,
  bio: json['bio'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  languages: (json['languages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  styles: (json['styles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  gear: json['gear'] as Map<String, dynamic>?,
  travelRadiusKm: (json['travel_radius_km'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProProfileUpdateRequestToJson(
  _ProProfileUpdateRequest instance,
) => <String, dynamic>{
  'display_name': instance.displayName,
  'headline': instance.headline,
  'cover_media_asset_id': instance.coverMediaAssetId,
  'bio': instance.bio,
  'city': instance.city,
  'country': instance.country,
  'languages': instance.languages,
  'styles': instance.styles,
  'gear': instance.gear,
  'travel_radius_km': instance.travelRadiusKm,
};
