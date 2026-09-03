// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadPayload _$UploadPayloadFromJson(Map<String, dynamic> json) =>
    _UploadPayload(
      method: json['method'] as String,
      url: json['url'] as String,
      headers: json['headers'] as Map<String, dynamic>?,
      storageKey: json['storage_key'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$UploadPayloadToJson(_UploadPayload instance) =>
    <String, dynamic>{
      'method': instance.method,
      'url': instance.url,
      'headers': instance.headers,
      'storage_key': instance.storageKey,
      'expires_in': instance.expiresIn,
    };
