// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduling_availability_rule_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchedulingAvailabilityRuleView _$SchedulingAvailabilityRuleViewFromJson(
  Map<String, dynamic> json,
) => _SchedulingAvailabilityRuleView(
  weekday: (json['weekday'] as num).toInt(),
  startLocal: json['start_local'] as String,
  endLocal: json['end_local'] as String,
  timezone: json['timezone'] as String,
  locationMode: json['location_mode'] == null
      ? AvailabilityLocationMode.both
      : AvailabilityLocationMode.fromJson(json['location_mode'] as String),
  id: json['id'] as String,
  proUserId: json['pro_user_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SchedulingAvailabilityRuleViewToJson(
  _SchedulingAvailabilityRuleView instance,
) => <String, dynamic>{
  'weekday': instance.weekday,
  'start_local': instance.startLocal,
  'end_local': instance.endLocal,
  'timezone': instance.timezone,
  'location_mode': instance.locationMode,
  'id': instance.id,
  'pro_user_id': instance.proUserId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
