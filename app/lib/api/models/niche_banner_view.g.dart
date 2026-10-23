// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'niche_banner_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NicheBannerView _$NicheBannerViewFromJson(Map<String, dynamic> json) =>
    _NicheBannerView(
      style: NicheBannerStyle.fromJson(json['style'] as String),
      name: json['name'] as String,
      tagline: json['tagline'] as String?,
      image: json['image'] == null
          ? null
          : NicheBannerImageView.fromJson(
              json['image'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$NicheBannerViewToJson(_NicheBannerView instance) =>
    <String, dynamic>{
      'style': instance.style,
      'name': instance.name,
      'tagline': instance.tagline,
      'image': instance.image,
    };
