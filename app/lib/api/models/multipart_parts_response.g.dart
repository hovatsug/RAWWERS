// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multipart_parts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MultipartPartsResponse _$MultipartPartsResponseFromJson(
  Map<String, dynamic> json,
) => _MultipartPartsResponse(
  partSize: (json['part_size'] as num).toInt(),
  partCount: (json['part_count'] as num).toInt(),
  parts: (json['parts'] as List<dynamic>)
      .map((e) => MultipartPartView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MultipartPartsResponseToJson(
  _MultipartPartsResponse instance,
) => <String, dynamic>{
  'part_size': instance.partSize,
  'part_count': instance.partCount,
  'parts': instance.parts,
};
