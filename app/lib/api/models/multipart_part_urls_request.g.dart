// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multipart_part_urls_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MultipartPartUrlsRequest _$MultipartPartUrlsRequestFromJson(
  Map<String, dynamic> json,
) => _MultipartPartUrlsRequest(
  partNumbers: (json['part_numbers'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$MultipartPartUrlsRequestToJson(
  _MultipartPartUrlsRequest instance,
) => <String, dynamic>{'part_numbers': instance.partNumbers};
