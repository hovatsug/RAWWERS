// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_rule_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityRuleItem _$AvailabilityRuleItemFromJson(
  Map<String, dynamic> json,
) => _AvailabilityRuleItem(
  weekday: (json['weekday'] as num).toInt(),
  startLocal: json['start_local'] as String,
  endLocal: json['end_local'] as String,
  timezone: json['timezone'] as String,
  locationMode: json['location_mode'] == null
      ? AvailabilityLocationMode.both
      : AvailabilityLocationMode.fromJson(json['location_mode'] as String),
);

Map<String, dynamic> _$AvailabilityRuleItemToJson(
  _AvailabilityRuleItem instance,
) => <String, dynamic>{
  'weekday': instance.weekday,
  'start_local': instance.startLocal,
  'end_local': instance.endLocal,
  'timezone': instance.timezone,
  'location_mode': instance.locationMode,
};
