// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_preference_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientPreferenceUpdateRequest _$ClientPreferenceUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ClientPreferenceUpdateRequest(
  preferredNiches: (json['preferred_niches'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  budgetMin: json['budget_min'],
  budgetMax: json['budget_max'],
  styleTags: (json['style_tags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  location: json['location'] as Map<String, dynamic>?,
  consentDefault: json['consent_default'] == null
      ? GigConsentLevel.none
      : GigConsentLevel.fromJson(json['consent_default'] as String),
);

Map<String, dynamic> _$ClientPreferenceUpdateRequestToJson(
  _ClientPreferenceUpdateRequest instance,
) => <String, dynamic>{
  'preferred_niches': instance.preferredNiches,
  'budget_min': instance.budgetMin,
  'budget_max': instance.budgetMax,
  'style_tags': instance.styleTags,
  'location': instance.location,
  'consent_default': instance.consentDefault,
};
