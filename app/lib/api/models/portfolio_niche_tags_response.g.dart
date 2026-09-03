// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_niche_tags_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PortfolioNicheTagsResponse _$PortfolioNicheTagsResponseFromJson(
  Map<String, dynamic> json,
) => _PortfolioNicheTagsResponse(
  mediaAssetId: json['media_asset_id'] as String,
  nicheSlugs: (json['niche_slugs'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PortfolioNicheTagsResponseToJson(
  _PortfolioNicheTagsResponse instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'niche_slugs': instance.nicheSlugs,
};
