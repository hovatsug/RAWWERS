// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConsentView _$ConsentViewFromJson(Map<String, dynamic> json) => _ConsentView(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  channel: ConsentChannel.fromJson(json['channel'] as String),
  scope: ConsentScope.fromJson(json['scope'] as String),
  granted: json['granted'] as bool,
  grantedAt: DateTime.parse(json['granted_at'] as String),
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
  source: json['source'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ConsentViewToJson(_ConsentView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'channel': instance.channel,
      'scope': instance.scope,
      'granted': instance.granted,
      'granted_at': instance.grantedAt.toIso8601String(),
      'revoked_at': instance.revokedAt?.toIso8601String(),
      'source': instance.source,
      'metadata': instance.metadata,
    };
