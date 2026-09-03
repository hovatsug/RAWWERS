// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_progress_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MilestoneProgressView _$MilestoneProgressViewFromJson(
  Map<String, dynamic> json,
) => _MilestoneProgressView(
  milestoneId: json['milestone_id'] as String,
  status: MilestoneProgressStatus.fromJson(json['status'] as String),
  progressValue: json['progress_value'] as String,
  progressMeta: json['progress_meta'] as Map<String, dynamic>?,
  startedAt: DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  lastEvaluatedAt: json['last_evaluated_at'] == null
      ? null
      : DateTime.parse(json['last_evaluated_at'] as String),
  completionsCount: (json['completions_count'] as num?)?.toInt() ?? 0,
  lastCompletedAt: json['last_completed_at'] == null
      ? null
      : DateTime.parse(json['last_completed_at'] as String),
);

Map<String, dynamic> _$MilestoneProgressViewToJson(
  _MilestoneProgressView instance,
) => <String, dynamic>{
  'milestone_id': instance.milestoneId,
  'status': instance.status,
  'progress_value': instance.progressValue,
  'progress_meta': instance.progressMeta,
  'started_at': instance.startedAt.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'last_evaluated_at': instance.lastEvaluatedAt?.toIso8601String(),
  'completions_count': instance.completionsCount,
  'last_completed_at': instance.lastCompletedAt?.toIso8601String(),
};
