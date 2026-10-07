// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multipart_part_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MultipartPartView _$MultipartPartViewFromJson(Map<String, dynamic> json) =>
    _MultipartPartView(
      partNumber: (json['part_number'] as num).toInt(),
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$MultipartPartViewToJson(_MultipartPartView instance) =>
    <String, dynamic>{
      'part_number': instance.partNumber,
      'size': instance.size,
    };
