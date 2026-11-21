// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation_video_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresentationVideoUploadResponse _$PresentationVideoUploadResponseFromJson(
  Map<String, dynamic> json,
) => _PresentationVideoUploadResponse(
  mediaAssetId: json['media_asset_id'] as String,
  uploadUrl: json['upload_url'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$PresentationVideoUploadResponseToJson(
  _PresentationVideoUploadResponse instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'upload_url': instance.uploadUrl,
  'status': instance.status,
};
