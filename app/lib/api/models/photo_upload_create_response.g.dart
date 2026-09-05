// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotoUploadCreateResponse _$PhotoUploadCreateResponseFromJson(
  Map<String, dynamic> json,
) => _PhotoUploadCreateResponse(
  mediaAssetId: json['media_asset_id'] as String,
  upload: UploadPayload.fromJson(json['upload'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PhotoUploadCreateResponseToJson(
  _PhotoUploadCreateResponse instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'upload': instance.upload,
};
