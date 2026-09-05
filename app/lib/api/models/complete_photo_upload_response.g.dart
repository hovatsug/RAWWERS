// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_photo_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompletePhotoUploadResponse _$CompletePhotoUploadResponseFromJson(
  Map<String, dynamic> json,
) => _CompletePhotoUploadResponse(
  ok: json['ok'] as bool,
  currentStatus: json['current_status'] as String,
);

Map<String, dynamic> _$CompletePhotoUploadResponseToJson(
  _CompletePhotoUploadResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'current_status': instance.currentStatus,
};
