// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_rule_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityRuleInput _$AvailabilityRuleInputFromJson(
  Map<String, dynamic> json,
) => _AvailabilityRuleInput(
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
);

Map<String, dynamic> _$AvailabilityRuleInputToJson(
  _AvailabilityRuleInput instance,
) => <String, dynamic>{
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
};
