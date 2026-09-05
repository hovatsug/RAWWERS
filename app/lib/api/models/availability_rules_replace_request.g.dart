// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_rules_replace_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailabilityRulesReplaceRequest _$AvailabilityRulesReplaceRequestFromJson(
  Map<String, dynamic> json,
) => _AvailabilityRulesReplaceRequest(
  rules: (json['rules'] as List<dynamic>?)
      ?.map((e) => AvailabilityRuleItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AvailabilityRulesReplaceRequestToJson(
  _AvailabilityRulesReplaceRequest instance,
) => <String, dynamic>{'rules': instance.rules};
