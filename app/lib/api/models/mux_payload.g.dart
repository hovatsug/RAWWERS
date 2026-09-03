// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mux_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuxPayload _$MuxPayloadFromJson(Map<String, dynamic> json) => _MuxPayload(
  directUploadId: json['direct_upload_id'] as String,
  uploadUrl: json['upload_url'] as String,
  expiresIn: (json['expires_in'] as num?)?.toInt(),
);

Map<String, dynamic> _$MuxPayloadToJson(_MuxPayload instance) =>
    <String, dynamic>{
      'direct_upload_id': instance.directUploadId,
      'upload_url': instance.uploadUrl,
      'expires_in': instance.expiresIn,
    };
