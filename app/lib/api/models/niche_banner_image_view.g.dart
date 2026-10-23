// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'niche_banner_image_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NicheBannerImageView _$NicheBannerImageViewFromJson(
  Map<String, dynamic> json,
) => _NicheBannerImageView(
  mediaAssetId: json['media_asset_id'] as String,
  tileUrl: json['tile_url'] as String,
  heroUrl: json['hero_url'] as String,
  placeholder: json['placeholder'] as String,
  altText: json['alt_text'] as String,
  focalX: (json['focal_x'] as num).toDouble(),
  focalY: (json['focal_y'] as num).toDouble(),
  scrimOpacity: (json['scrim_opacity'] as num).toDouble(),
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
);

Map<String, dynamic> _$NicheBannerImageViewToJson(
  _NicheBannerImageView instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'tile_url': instance.tileUrl,
  'hero_url': instance.heroUrl,
  'placeholder': instance.placeholder,
  'alt_text': instance.altText,
  'focal_x': instance.focalX,
  'focal_y': instance.focalY,
  'scrim_opacity': instance.scrimOpacity,
  'width': instance.width,
  'height': instance.height,
};
