// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_event_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CycleEventView _$CycleEventViewFromJson(Map<String, dynamic> json) =>
    _CycleEventView(
      id: json['id'] as String,
      cycleId: json['cycle_id'] as String,
      userId: json['user_id'] as String,
      eventType: json['event_type'] as String,
      pointsDelta: (json['points_delta'] as num).toInt(),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CycleEventViewToJson(_CycleEventView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cycle_id': instance.cycleId,
      'user_id': instance.userId,
      'event_type': instance.eventType,
      'points_delta': instance.pointsDelta,
      'reference_type': instance.referenceType,
      'reference_id': instance.referenceId,
      'created_at': instance.createdAt.toIso8601String(),
    };
