// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multipart_part_url.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MultipartPartUrl _$MultipartPartUrlFromJson(Map<String, dynamic> json) =>
    _MultipartPartUrl(
      partNumber: (json['part_number'] as num).toInt(),
      url: json['url'] as String,
    );

Map<String, dynamic> _$MultipartPartUrlToJson(_MultipartPartUrl instance) =>
    <String, dynamic>{'part_number': instance.partNumber, 'url': instance.url};
