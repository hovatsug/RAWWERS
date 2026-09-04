// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_availability_rule_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingAvailabilityRuleView _$OnboardingAvailabilityRuleViewFromJson(
  Map<String, dynamic> json,
) => _OnboardingAvailabilityRuleView(
  id: json['id'] as String,
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
);

Map<String, dynamic> _$OnboardingAvailabilityRuleViewToJson(
  _OnboardingAvailabilityRuleView instance,
) => <String, dynamic>{
  'id': instance.id,
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
};
