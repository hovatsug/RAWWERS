// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduling_slot_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulingSlotView _$SchedulingSlotViewFromJson(Map<String, dynamic> json) =>
    _SchedulingSlotView(
      startAtUtc: DateTime.parse(json['start_at_utc'] as String),
      endAtUtc: DateTime.parse(json['end_at_utc'] as String),
      timezone: json['timezone'] as String,
      startLocal: json['start_local'] as String,
      endLocal: json['end_local'] as String,
    );

Map<String, dynamic> _$SchedulingSlotViewToJson(_SchedulingSlotView instance) =>
    <String, dynamic>{
      'start_at_utc': instance.startAtUtc.toIso8601String(),
      'end_at_utc': instance.endAtUtc.toIso8601String(),
      'timezone': instance.timezone,
      'start_local': instance.startLocal,
      'end_local': instance.endLocal,
    };
