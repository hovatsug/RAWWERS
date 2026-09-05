// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_gig_consent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateGigConsentRequest _$UpdateGigConsentRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateGigConsentRequest(
  consentLevel: GigConsentLevel.fromJson(json['consent_level'] as String),
  scope: json['scope'] as Map<String, dynamic>?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$UpdateGigConsentRequestToJson(
  _UpdateGigConsentRequest instance,
) => <String, dynamic>{
  'consent_level': instance.consentLevel,
  'scope': instance.scope,
  'reason': instance.reason,
};
