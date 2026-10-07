// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multipart_start_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MultipartStartResponse _$MultipartStartResponseFromJson(
  Map<String, dynamic> json,
) => _MultipartStartResponse(
  partSize: (json['part_size'] as num).toInt(),
  partCount: (json['part_count'] as num).toInt(),
);

Map<String, dynamic> _$MultipartStartResponseToJson(
  _MultipartStartResponse instance,
) => <String, dynamic>{
  'part_size': instance.partSize,
  'part_count': instance.partCount,
};
