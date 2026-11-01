// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_problem_report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateProblemReportRequest _$CreateProblemReportRequestFromJson(
  Map<String, dynamic> json,
) => _CreateProblemReportRequest(
  reason: ProblemReportReason.fromJson(json['reason'] as String),
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateProblemReportRequestToJson(
  _CreateProblemReportRequest instance,
) => <String, dynamic>{'reason': instance.reason, 'note': instance.note};
