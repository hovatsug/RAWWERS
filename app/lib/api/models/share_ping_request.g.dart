// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_ping_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharePingRequest _$SharePingRequestFromJson(Map<String, dynamic> json) =>
    _SharePingRequest(
      secondsViewed: (json['seconds_viewed'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$SharePingRequestToJson(_SharePingRequest instance) =>
    <String, dynamic>{'seconds_viewed': instance.secondsViewed};
