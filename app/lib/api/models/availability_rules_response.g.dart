// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_rules_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityRulesResponse _$AvailabilityRulesResponseFromJson(
  Map<String, dynamic> json,
) => _AvailabilityRulesResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => AvailabilityRuleView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AvailabilityRulesResponseToJson(
  _AvailabilityRulesResponse instance,
) => <String, dynamic>{'items': instance.items};
