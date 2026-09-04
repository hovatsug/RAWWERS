// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_availability_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicAvailabilityResponse _$PublicAvailabilityResponseFromJson(
  Map<String, dynamic> json,
) => _PublicAvailabilityResponse(
  proUserId: json['pro_user_id'] as String,
  rules: (json['rules'] as List<dynamic>)
      .map(
        (e) => PublicAvailabilityRuleView.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  blackouts: (json['blackouts'] as List<dynamic>)
      .map((e) => BlackoutView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PublicAvailabilityResponseToJson(
  _PublicAvailabilityResponse instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'rules': instance.rules,
  'blackouts': instance.blackouts,
};
