// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_onboarding_checks_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProOnboardingChecksResponse _$ProOnboardingChecksResponseFromJson(
  Map<String, dynamic> json,
) => _ProOnboardingChecksResponse(
  status: ProOnboardingStatus.fromJson(json['status'] as String),
  checks: json['checks'] as Map<String, dynamic>?,
  missing: (json['missing'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ProOnboardingChecksResponseToJson(
  _ProOnboardingChecksResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'checks': instance.checks,
  'missing': instance.missing,
};
