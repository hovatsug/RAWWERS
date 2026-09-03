// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_rule_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityRuleView _$AvailabilityRuleViewFromJson(
  Map<String, dynamic> json,
) => _AvailabilityRuleView(
  id: json['id'] as String,
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
);

Map<String, dynamic> _$AvailabilityRuleViewToJson(
  _AvailabilityRuleView instance,
) => <String, dynamic>{
  'id': instance.id,
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
};
