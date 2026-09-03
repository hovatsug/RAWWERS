// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_public_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPublicProfileResponse _$ProPublicProfileResponseFromJson(
  Map<String, dynamic> json,
) => _ProPublicProfileResponse(
  proUserId: json['pro_user_id'] as String,
  displayName: json['display_name'] as String?,
  headline: json['headline'] as String?,
  coverMediaAssetId: json['cover_media_asset_id'] as String?,
  bio: json['bio'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  styles: (json['styles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  packages: (json['packages'] as List<dynamic>)
      .map((e) => PublicProPackageView.fromJson(e as Map<String, dynamic>))
      .toList(),
  portfolioPhotos: (json['portfolio_photos'] as List<dynamic>)
      .map((e) => PublicPortfolioPhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
  portfolioVideos: (json['portfolio_videos'] as List<dynamic>)
      .map((e) => PublicPortfolioVideo.fromJson(e as Map<String, dynamic>))
      .toList(),
  gigsCompleted: (json['gigs_completed'] as num).toInt(),
  gigsCancelled: (json['gigs_cancelled'] as num).toInt(),
  disputesCount: (json['disputes_count'] as num).toInt(),
  avgResponseMinutes: (json['avg_response_minutes'] as num?)?.toInt(),
  avgRating: json['avg_rating'] as String,
  reviewCount: (json['review_count'] as num).toInt(),
  rankingScore: json['ranking_score'] as String,
);

Map<String, dynamic> _$ProPublicProfileResponseToJson(
  _ProPublicProfileResponse instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'display_name': instance.displayName,
  'headline': instance.headline,
  'cover_media_asset_id': instance.coverMediaAssetId,
  'bio': instance.bio,
  'city': instance.city,
  'country': instance.country,
  'styles': instance.styles,
  'packages': instance.packages,
  'portfolio_photos': instance.portfolioPhotos,
  'portfolio_videos': instance.portfolioVideos,
  'gigs_completed': instance.gigsCompleted,
  'gigs_cancelled': instance.gigsCancelled,
  'disputes_count': instance.disputesCount,
  'avg_response_minutes': instance.avgResponseMinutes,
  'avg_rating': instance.avgRating,
  'review_count': instance.reviewCount,
  'ranking_score': instance.rankingScore,
};
