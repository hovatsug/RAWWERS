// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blackout_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BlackoutCreateRequest _$BlackoutCreateRequestFromJson(
  Map<String, dynamic> json,
) => _BlackoutCreateRequest(
  startAt: DateTime.parse(json['start_at'] as String),
  endAt: DateTime.parse(json['end_at'] as String),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$BlackoutCreateRequestToJson(
  _BlackoutCreateRequest instance,
) => <String, dynamic>{
  'start_at': instance.startAt.toIso8601String(),
  'end_at': instance.endAt.toIso8601String(),
  'reason': instance.reason,
};
