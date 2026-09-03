// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_gallery_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublishGalleryResponse _$PublishGalleryResponseFromJson(
  Map<String, dynamic> json,
) => _PublishGalleryResponse(
  ok: json['ok'] as bool,
  status: ProofGalleryStatus.fromJson(json['status'] as String),
);

Map<String, dynamic> _$PublishGalleryResponseToJson(
  _PublishGalleryResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'status': instance.status};
