// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotoUploadCreateRequest _$PhotoUploadCreateRequestFromJson(
  Map<String, dynamic> json,
) => _PhotoUploadCreateRequest(
  purpose: MediaPurpose.fromJson(json['purpose'] as String),
  contentType: json['content_type'] as String,
  fileName: json['file_name'] as String?,
);

Map<String, dynamic> _$PhotoUploadCreateRequestToJson(
  _PhotoUploadCreateRequest instance,
) => <String, dynamic>{
  'purpose': instance.purpose,
  'content_type': instance.contentType,
  'file_name': instance.fileName,
};
