// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replace_availability_rules_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReplaceAvailabilityRulesRequest _$ReplaceAvailabilityRulesRequestFromJson(
  Map<String, dynamic> json,
) => _ReplaceAvailabilityRulesRequest(
  rules: (json['rules'] as List<dynamic>)
      .map((e) => AvailabilityRuleInput.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReplaceAvailabilityRulesRequestToJson(
  _ReplaceAvailabilityRulesRequest instance,
) => <String, dynamic>{'rules': instance.rules};
