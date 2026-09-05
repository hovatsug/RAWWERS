// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_ping_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharePingResponse _$SharePingResponseFromJson(Map<String, dynamic> json) =>
    _SharePingResponse(
      ok: json['ok'] as bool,
      accumulatedSeconds: (json['accumulated_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$SharePingResponseToJson(_SharePingResponse instance) =>
    <String, dynamic>{
      'ok': instance.ok,
      'accumulated_seconds': instance.accumulatedSeconds,
    };
