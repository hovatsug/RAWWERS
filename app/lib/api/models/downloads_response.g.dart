// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloads_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadsResponse _$DownloadsResponseFromJson(Map<String, dynamic> json) =>
    _DownloadsResponse(
      galleryId: json['gallery_id'] as String,
      urls: json['urls'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DownloadsResponseToJson(_DownloadsResponse instance) =>
    <String, dynamic>{'gallery_id': instance.galleryId, 'urls': instance.urls};
