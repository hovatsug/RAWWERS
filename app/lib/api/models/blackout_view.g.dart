// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blackout_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BlackoutView _$BlackoutViewFromJson(Map<String, dynamic> json) =>
    _BlackoutView(
      id: json['id'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      reason: json['reason'] as String?,
      deprecationNotice: json['deprecation_notice'] as String?,
    );

Map<String, dynamic> _$BlackoutViewToJson(_BlackoutView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_at': instance.startAt.toIso8601String(),
      'end_at': instance.endAt.toIso8601String(),
      'reason': instance.reason,
      'deprecation_notice': instance.deprecationNotice,
    };
