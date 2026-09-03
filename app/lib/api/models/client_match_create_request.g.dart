// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_match_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientMatchCreateRequest _$ClientMatchCreateRequestFromJson(
  Map<String, dynamic> json,
) => _ClientMatchCreateRequest(
  country: json['country'] as String,
  city: json['city'] as String,
  nicheSlug: json['niche_slug'] as String,
  budgetMin: json['budget_min'],
  budgetMax: json['budget_max'],
  styleTags: (json['style_tags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ClientMatchCreateRequestToJson(
  _ClientMatchCreateRequest instance,
) => <String, dynamic>{
  'country': instance.country,
  'city': instance.city,
  'niche_slug': instance.nicheSlug,
  'budget_min': instance.budgetMin,
  'budget_max': instance.budgetMax,
  'style_tags': instance.styleTags,
};
