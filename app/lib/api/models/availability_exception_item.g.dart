// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_exception_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityExceptionItem _$AvailabilityExceptionItemFromJson(
  Map<String, dynamic> json,
) => _AvailabilityExceptionItem(
  startAtUtc: DateTime.parse(json['start_at_utc'] as String),
  endAtUtc: DateTime.parse(json['end_at_utc'] as String),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$AvailabilityExceptionItemToJson(
  _AvailabilityExceptionItem instance,
) => <String, dynamic>{
  'start_at_utc': instance.startAtUtc.toIso8601String(),
  'end_at_utc': instance.endAtUtc.toIso8601String(),
  'reason': instance.reason,
};
