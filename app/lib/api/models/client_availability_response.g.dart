// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_availability_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientAvailabilityResponse _$ClientAvailabilityResponseFromJson(
  Map<String, dynamic> json,
) => _ClientAvailabilityResponse(
  timezone: json['timezone'] as String,
  hasSchedule: json['has_schedule'] as bool,
  noticeHours: (json['notice_hours'] as num).toInt(),
  days: (json['days'] as List<dynamic>?)
      ?.map((e) => ClientAvailabilityDay.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClientAvailabilityResponseToJson(
  _ClientAvailabilityResponse instance,
) => <String, dynamic>{
  'timezone': instance.timezone,
  'has_schedule': instance.hasSchedule,
  'notice_hours': instance.noticeHours,
  'days': instance.days,
};
