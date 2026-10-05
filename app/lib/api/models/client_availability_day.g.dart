// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_availability_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientAvailabilityDay _$ClientAvailabilityDayFromJson(
  Map<String, dynamic> json,
) => _ClientAvailabilityDay(
  date: DateTime.parse(json['date'] as String),
  open: json['open'] as bool,
  startTimes: (json['start_times'] as List<dynamic>?)
      ?.map((e) => ClientAvailabilityStart.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClientAvailabilityDayToJson(
  _ClientAvailabilityDay instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'open': instance.open,
  'start_times': instance.startTimes,
};
