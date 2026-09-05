// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_discover_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientDiscoverCard _$ClientDiscoverCardFromJson(Map<String, dynamic> json) =>
    _ClientDiscoverCard(
      proUserId: json['pro_user_id'] as String,
      displayName: json['display_name'] as String?,
      headline: json['headline'] as String?,
      coverMediaAssetId: json['cover_media_asset_id'] as String?,
      coverUrl: json['cover_url'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      minPrice: json['min_price'] as String?,
      maxPrice: json['max_price'] as String?,
      currency: json['currency'] as String,
      avgRating: json['avg_rating'] as String,
      reviewCount: (json['review_count'] as num).toInt(),
      topNiches: (json['top_niches'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      portfolioPhotoCount: (json['portfolio_photo_count'] as num).toInt(),
      portfolioVideoCount: (json['portfolio_video_count'] as num).toInt(),
    );

Map<String, dynamic> _$ClientDiscoverCardToJson(_ClientDiscoverCard instance) =>
    <String, dynamic>{
      'pro_user_id': instance.proUserId,
      'display_name': instance.displayName,
      'headline': instance.headline,
      'cover_media_asset_id': instance.coverMediaAssetId,
      'cover_url': instance.coverUrl,
      'city': instance.city,
      'country': instance.country,
      'min_price': instance.minPrice,
      'max_price': instance.maxPrice,
      'currency': instance.currency,
      'avg_rating': instance.avgRating,
      'review_count': instance.reviewCount,
      'top_niches': instance.topNiches,
      'portfolio_photo_count': instance.portfolioPhotoCount,
      'portfolio_video_count': instance.portfolioVideoCount,
    };
