// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multipart_part_urls_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MultipartPartUrlsResponse _$MultipartPartUrlsResponseFromJson(
  Map<String, dynamic> json,
) => _MultipartPartUrlsResponse(
  parts: (json['parts'] as List<dynamic>)
      .map((e) => MultipartPartUrl.fromJson(e as Map<String, dynamic>))
      .toList(),
  expiresIn: (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$MultipartPartUrlsResponseToJson(
  _MultipartPartUrlsResponse instance,
) => <String, dynamic>{
  'parts': instance.parts,
  'expires_in': instance.expiresIn,
};
