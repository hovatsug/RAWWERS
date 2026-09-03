// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_portfolio_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicPortfolioPhoto _$PublicPortfolioPhotoFromJson(
  Map<String, dynamic> json,
) => _PublicPortfolioPhoto(
  mediaAssetId: json['media_asset_id'] as String,
  thumbnailUrl: json['thumbnail_url'] as String?,
  watermarkPreviewUrl: json['watermark_preview_url'] as String?,
);

Map<String, dynamic> _$PublicPortfolioPhotoToJson(
  _PublicPortfolioPhoto instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'thumbnail_url': instance.thumbnailUrl,
  'watermark_preview_url': instance.watermarkPreviewUrl,
};
