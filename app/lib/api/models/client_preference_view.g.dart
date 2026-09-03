// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_preference_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientPreferenceView _$ClientPreferenceViewFromJson(
  Map<String, dynamic> json,
) => _ClientPreferenceView(
  preferredNiches: (json['preferred_niches'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  budgetMin: json['budget_min'] as String?,
  budgetMax: json['budget_max'] as String?,
  styleTags: (json['style_tags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  location: json['location'] as Map<String, dynamic>?,
  consentDefault: GigConsentLevel.fromJson(json['consent_default'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ClientPreferenceViewToJson(
  _ClientPreferenceView instance,
) => <String, dynamic>{
  'preferred_niches': instance.preferredNiches,
  'budget_min': instance.budgetMin,
  'budget_max': instance.budgetMax,
  'style_tags': instance.styleTags,
  'location': instance.location,
  'consent_default': instance.consentDefault,
  'updated_at': instance.updatedAt.toIso8601String(),
};
