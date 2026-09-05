// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_portfolio_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPortfolioItem _$ProPortfolioItemFromJson(Map<String, dynamic> json) =>
    _ProPortfolioItem(
      mediaAssetId: json['media_asset_id'] as String,
      kind: json['kind'] as String,
      status: json['status'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      nicheSlugs: (json['niche_slugs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isCover: json['is_cover'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProPortfolioItemToJson(_ProPortfolioItem instance) =>
    <String, dynamic>{
      'media_asset_id': instance.mediaAssetId,
      'kind': instance.kind,
      'status': instance.status,
      'thumbnail_url': instance.thumbnailUrl,
      'niche_slugs': instance.nicheSlugs,
      'is_cover': instance.isCover,
      'created_at': instance.createdAt.toIso8601String(),
    };
