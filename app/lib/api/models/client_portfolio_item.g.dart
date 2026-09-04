// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_portfolio_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientPortfolioItem _$ClientPortfolioItemFromJson(Map<String, dynamic> json) =>
    _ClientPortfolioItem(
      mediaAssetId: json['media_asset_id'] as String,
      kind: json['kind'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$ClientPortfolioItemToJson(
  _ClientPortfolioItem instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'kind': instance.kind,
  'thumbnail_url': instance.thumbnailUrl,
};
