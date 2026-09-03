// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProCard _$ProCardFromJson(Map<String, dynamic> json) => _ProCard(
  proUserId: json['pro_user_id'] as String,
  displayName: json['display_name'] as String?,
  city: json['city'] as String?,
  styles: (json['styles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  minPrice: json['min_price'] as String?,
  currency: json['currency'] as String,
  portfolioPhotoCount: (json['portfolio_photo_count'] as num).toInt(),
  portfolioVideoCount: (json['portfolio_video_count'] as num).toInt(),
  avgRating: json['avg_rating'] as String,
  reviewCount: (json['review_count'] as num).toInt(),
  rankingScore: json['ranking_score'] as String,
  primaryNicheId: json['primary_niche_id'] as String?,
  topNiches: (json['top_niches'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$ProCardToJson(_ProCard instance) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'display_name': instance.displayName,
  'city': instance.city,
  'styles': instance.styles,
  'min_price': instance.minPrice,
  'currency': instance.currency,
  'portfolio_photo_count': instance.portfolioPhotoCount,
  'portfolio_video_count': instance.portfolioVideoCount,
  'avg_rating': instance.avgRating,
  'review_count': instance.reviewCount,
  'ranking_score': instance.rankingScore,
  'primary_niche_id': instance.primaryNicheId,
  'top_niches': instance.topNiches,
};
