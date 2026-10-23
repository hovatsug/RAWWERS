// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_findings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyFindingsResponse _$MyFindingsResponseFromJson(Map<String, dynamic> json) =>
    _MyFindingsResponse(
      strikes: (json['strikes'] as num).toInt(),
      pause: json['pause'] == null
          ? null
          : BookingPauseView.fromJson(json['pause'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => FindingView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyFindingsResponseToJson(_MyFindingsResponse instance) =>
    <String, dynamic>{
      'strikes': instance.strikes,
      'pause': instance.pause,
      'items': instance.items,
    };
