// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchRequest _$MatchRequestFromJson(Map<String, dynamic> json) =>
    _MatchRequest(
      city: json['city'] as String?,
      styles: (json['styles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      budget: json['budget'],
      dateRange: json['date_range'] as Map<String, dynamic>?,
      purpose: json['purpose'] as String?,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$MatchRequestToJson(_MatchRequest instance) =>
    <String, dynamic>{
      'city': instance.city,
      'styles': instance.styles,
      'budget': instance.budget,
      'date_range': instance.dateRange,
      'purpose': instance.purpose,
      'limit': instance.limit,
    };
