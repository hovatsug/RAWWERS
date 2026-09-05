// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_onboarding_start_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProOnboardingStartRequest _$ProOnboardingStartRequestFromJson(
  Map<String, dynamic> json,
) => _ProOnboardingStartRequest(
  city: json['city'] as String,
  country: json['country'] as String,
  inviteCode: json['invite_code'] as String?,
);

Map<String, dynamic> _$ProOnboardingStartRequestToJson(
  _ProOnboardingStartRequest instance,
) => <String, dynamic>{
  'city': instance.city,
  'country': instance.country,
  'invite_code': instance.inviteCode,
};
