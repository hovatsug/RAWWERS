// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_pro_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientProProfileResponse _$ClientProProfileResponseFromJson(
  Map<String, dynamic> json,
) => _ClientProProfileResponse(
  proUserId: json['pro_user_id'] as String,
  displayName: json['display_name'] as String?,
  headline: json['headline'] as String?,
  coverMediaAssetId: json['cover_media_asset_id'] as String?,
  bio: json['bio'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  styles: (json['styles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  avgRating: json['avg_rating'] as String,
  reviewCount: (json['review_count'] as num).toInt(),
  portfolioPhotoCount: (json['portfolio_photo_count'] as num).toInt(),
  portfolioVideoCount: (json['portfolio_video_count'] as num).toInt(),
  packages: (json['packages'] as List<dynamic>?)
      ?.map((e) => ClientProfilePackage.fromJson(e as Map<String, dynamic>))
      .toList(),
  portfolioPreviewAssetIds:
      (json['portfolio_preview_asset_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  isGuestView: json['is_guest_view'] as bool? ?? false,
);

Map<String, dynamic> _$ClientProProfileResponseToJson(
  _ClientProProfileResponse instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'display_name': instance.displayName,
  'headline': instance.headline,
  'cover_media_asset_id': instance.coverMediaAssetId,
  'bio': instance.bio,
  'city': instance.city,
  'country': instance.country,
  'styles': instance.styles,
  'avg_rating': instance.avgRating,
  'review_count': instance.reviewCount,
  'portfolio_photo_count': instance.portfolioPhotoCount,
  'portfolio_video_count': instance.portfolioVideoCount,
  'packages': instance.packages,
  'portfolio_preview_asset_ids': instance.portfolioPreviewAssetIds,
  'is_guest_view': instance.isGuestView,
};
