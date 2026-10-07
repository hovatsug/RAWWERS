// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_block_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionBlockInput _$SessionBlockInputFromJson(Map<String, dynamic> json) =>
    _SessionBlockInput(
      label: SessionBlockLabel.fromJson(json['label'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );

Map<String, dynamic> _$SessionBlockInputToJson(_SessionBlockInput instance) =>
    <String, dynamic>{
      'label': instance.label,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };
