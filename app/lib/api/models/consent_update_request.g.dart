// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConsentUpdateRequest _$ConsentUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ConsentUpdateRequest(
  channel: ConsentChannel.fromJson(json['channel'] as String),
  scope: ConsentScope.fromJson(json['scope'] as String),
  granted: json['granted'] as bool,
  source: json['source'] as String? ?? 'in_app_toggle',
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ConsentUpdateRequestToJson(
  _ConsentUpdateRequest instance,
) => <String, dynamic>{
  'channel': instance.channel,
  'scope': instance.scope,
  'granted': instance.granted,
  'source': instance.source,
  'metadata': instance.metadata,
};
