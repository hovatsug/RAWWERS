// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsCreateRequest _$AnalyticsCreateRequestFromJson(
  Map<String, dynamic> json,
) => _AnalyticsCreateRequest(
  eventName: json['event_name'] as String,
  properties: json['properties'] as Map<String, dynamic>?,
  sessionId: json['session_id'] as String?,
);

Map<String, dynamic> _$AnalyticsCreateRequestToJson(
  _AnalyticsCreateRequest instance,
) => <String, dynamic>{
  'event_name': instance.eventName,
  'properties': instance.properties,
  'session_id': instance.sessionId,
};
