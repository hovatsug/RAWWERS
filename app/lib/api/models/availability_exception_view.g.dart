// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_exception_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityExceptionView _$AvailabilityExceptionViewFromJson(
  Map<String, dynamic> json,
) => _AvailabilityExceptionView(
  startAtUtc: DateTime.parse(json['start_at_utc'] as String),
  endAtUtc: DateTime.parse(json['end_at_utc'] as String),
  reason: json['reason'] as String?,
  id: json['id'] as String,
  proUserId: json['pro_user_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AvailabilityExceptionViewToJson(
  _AvailabilityExceptionView instance,
) => <String, dynamic>{
  'start_at_utc': instance.startAtUtc.toIso8601String(),
  'end_at_utc': instance.endAtUtc.toIso8601String(),
  'reason': instance.reason,
  'id': instance.id,
  'pro_user_id': instance.proUserId,
  'created_at': instance.createdAt.toIso8601String(),
};
