// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation_video_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresentationVideoUploadRequest _$PresentationVideoUploadRequestFromJson(
  Map<String, dynamic> json,
) => _PresentationVideoUploadRequest(
  byteSize: (json['byte_size'] as num).toInt(),
  durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
  contentType: json['content_type'] as String?,
  requestId: json['request_id'] as String,
);

Map<String, dynamic> _$PresentationVideoUploadRequestToJson(
  _PresentationVideoUploadRequest instance,
) => <String, dynamic>{
  'byte_size': instance.byteSize,
  'duration_seconds': instance.durationSeconds,
  'content_type': instance.contentType,
  'request_id': instance.requestId,
};
