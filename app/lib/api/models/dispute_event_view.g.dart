// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_event_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisputeEventView _$DisputeEventViewFromJson(Map<String, dynamic> json) =>
    _DisputeEventView(
      id: json['id'] as String,
      disputeId: json['dispute_id'] as String,
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String,
      actorType: json['actor_type'] as String,
      actorUserId: json['actor_user_id'] as String?,
      note: json['note'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DisputeEventViewToJson(_DisputeEventView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dispute_id': instance.disputeId,
      'from_status': instance.fromStatus,
      'to_status': instance.toStatus,
      'actor_type': instance.actorType,
      'actor_user_id': instance.actorUserId,
      'note': instance.note,
      'payload': instance.payload,
      'created_at': instance.createdAt.toIso8601String(),
    };
