// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallSummaryResponse _$CallSummaryResponseFromJson(Map<String, dynamic> json) =>
    _CallSummaryResponse(
      id: json['id'] as String,
      summary: json['summary'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CallSummaryResponseToJson(
  _CallSummaryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'summary': instance.summary,
  'metadata': instance.metadata,
};
