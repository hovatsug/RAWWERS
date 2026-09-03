// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MilestoneView _$MilestoneViewFromJson(Map<String, dynamic> json) =>
    _MilestoneView(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      nameKey: json['name_key'] as String?,
      descriptionKey: json['description_key'] as String?,
      scope: MilestoneScope.fromJson(json['scope'] as String),
      nicheId: json['niche_id'] as String?,
      difficulty: MilestoneDifficulty.fromJson(json['difficulty'] as String),
      audience: MilestoneAudience.fromJson(json['audience'] as String),
      isRepeatable: json['is_repeatable'] as bool,
      cooldownDays: (json['cooldown_days'] as num?)?.toInt(),
      startAt: json['start_at'] == null
          ? null
          : DateTime.parse(json['start_at'] as String),
      endAt: json['end_at'] == null
          ? null
          : DateTime.parse(json['end_at'] as String),
      criteria: json['criteria'] as Map<String, dynamic>?,
      rewardRuleCode: json['reward_rule_code'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MilestoneViewToJson(_MilestoneView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'name_key': instance.nameKey,
      'description_key': instance.descriptionKey,
      'scope': instance.scope,
      'niche_id': instance.nicheId,
      'difficulty': instance.difficulty,
      'audience': instance.audience,
      'is_repeatable': instance.isRepeatable,
      'cooldown_days': instance.cooldownDays,
      'start_at': instance.startAt?.toIso8601String(),
      'end_at': instance.endAt?.toIso8601String(),
      'criteria': instance.criteria,
      'reward_rule_code': instance.rewardRuleCode,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
