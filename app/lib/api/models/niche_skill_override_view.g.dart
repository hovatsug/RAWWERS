// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'niche_skill_override_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NicheSkillOverrideView _$NicheSkillOverrideViewFromJson(
  Map<String, dynamic> json,
) => _NicheSkillOverrideView(
  tier: json['tier'] == null
      ? null
      : SkillTier.fromJson(json['tier'] as String),
  score: (json['score'] as num?)?.toInt(),
  verified: json['verified'] as bool?,
  by: json['by'] as String?,
  at: json['at'] == null ? null : DateTime.parse(json['at'] as String),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$NicheSkillOverrideViewToJson(
  _NicheSkillOverrideView instance,
) => <String, dynamic>{
  'tier': instance.tier,
  'score': instance.score,
  'verified': instance.verified,
  'by': instance.by,
  'at': instance.at?.toIso8601String(),
  'reason': instance.reason,
};
