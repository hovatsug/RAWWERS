// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_profile_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProProfileView _$ProProfileViewFromJson(Map<String, dynamic> json) =>
    _ProProfileView(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      headline: json['headline'] as String?,
      coverMediaAssetId: json['cover_media_asset_id'] as String?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      styles: (json['styles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      gear: json['gear'] as Map<String, dynamic>?,
      travelRadiusKm: (json['travel_radius_km'] as num?)?.toInt(),
      isAcceptingBookings: json['is_accepting_bookings'] as bool,
      completenessScore: (json['completeness_score'] as num).toInt(),
      kycStatus: json['kyc_status'] as String,
    );

Map<String, dynamic> _$ProProfileViewToJson(_ProProfileView instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
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
      'is_accepting_bookings': instance.isAcceptingBookings,
      'completeness_score': instance.completenessScore,
      'kyc_status': instance.kycStatus,
    };
