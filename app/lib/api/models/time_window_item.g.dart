// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_window_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeWindowItem _$TimeWindowItemFromJson(Map<String, dynamic> json) =>
    _TimeWindowItem(
      startAtUtc: DateTime.parse(json['start_at_utc'] as String),
      endAtUtc: DateTime.parse(json['end_at_utc'] as String),
    );

Map<String, dynamic> _$TimeWindowItemToJson(_TimeWindowItem instance) =>
    <String, dynamic>{
      'start_at_utc': instance.startAtUtc.toIso8601String(),
      'end_at_utc': instance.endAtUtc.toIso8601String(),
    };
