// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_portfolio_remove_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProPortfolioRemoveResponse _$ProPortfolioRemoveResponseFromJson(
  Map<String, dynamic> json,
) => _ProPortfolioRemoveResponse(
  mediaAssetId: json['media_asset_id'] as String,
  removed: json['removed'] as bool,
  coverCleared: json['cover_cleared'] as bool? ?? false,
);

Map<String, dynamic> _$ProPortfolioRemoveResponseToJson(
  _ProPortfolioRemoveResponse instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'removed': instance.removed,
  'cover_cleared': instance.coverCleared,
};
