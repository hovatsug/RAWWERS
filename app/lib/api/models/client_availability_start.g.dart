// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_availability_start.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientAvailabilityStart _$ClientAvailabilityStartFromJson(
  Map<String, dynamic> json,
) => _ClientAvailabilityStart(
  startAt: DateTime.parse(json['start_at'] as String),
  localTime: json['local_time'] as String,
);

Map<String, dynamic> _$ClientAvailabilityStartToJson(
  _ClientAvailabilityStart instance,
) => <String, dynamic>{
  'start_at': instance.startAt.toIso8601String(),
  'local_time': instance.localTime,
};
