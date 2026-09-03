// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_url_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignedUrlResponse _$SignedUrlResponseFromJson(Map<String, dynamic> json) =>
    _SignedUrlResponse(
      url: json['url'] as String,
      expiresInSeconds: (json['expires_in_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$SignedUrlResponseToJson(_SignedUrlResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
      'expires_in_seconds': instance.expiresInSeconds,
    };
