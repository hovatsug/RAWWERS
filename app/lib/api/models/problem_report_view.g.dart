// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_report_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProblemReportView _$ProblemReportViewFromJson(Map<String, dynamic> json) =>
    _ProblemReportView(
      id: json['id'] as String,
      gigId: json['gig_id'] as String,
      reason: ProblemReportReason.fromJson(json['reason'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProblemReportViewToJson(_ProblemReportView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'reason': instance.reason,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
    };
