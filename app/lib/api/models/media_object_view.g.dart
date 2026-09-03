// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_object_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaObjectView _$MediaObjectViewFromJson(Map<String, dynamic> json) =>
    _MediaObjectView(
      variant: json['variant'] as String,
      status: json['status'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$MediaObjectViewToJson(_MediaObjectView instance) =>
    <String, dynamic>{
      'variant': instance.variant,
      'status': instance.status,
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
    };
