// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_item_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GalleryItemView _$GalleryItemViewFromJson(Map<String, dynamic> json) =>
    _GalleryItemView(
      mediaAssetId: json['media_asset_id'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      watermarkPreviewUrl: json['watermark_preview_url'] as String?,
    );

Map<String, dynamic> _$GalleryItemViewToJson(_GalleryItemView instance) =>
    <String, dynamic>{
      'media_asset_id': instance.mediaAssetId,
      'sort_order': instance.sortOrder,
      'thumbnail_url': instance.thumbnailUrl,
      'watermark_preview_url': instance.watermarkPreviewUrl,
    };
