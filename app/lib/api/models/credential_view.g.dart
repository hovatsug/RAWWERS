// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CredentialView _$CredentialViewFromJson(Map<String, dynamic> json) =>
    _CredentialView(
      id: json['id'] as String,
      proUserId: json['pro_user_id'] as String,
      nicheId: json['niche_id'] as String,
      credentialCode: json['credential_code'] as String,
      displayName: json['display_name'] as String,
      tier: SkillTier.fromJson(json['tier'] as String),
      mode: CredentialMode.fromJson(json['mode'] as String),
      awardedAt: DateTime.parse(json['awarded_at'] as String),
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CredentialViewToJson(_CredentialView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pro_user_id': instance.proUserId,
      'niche_id': instance.nicheId,
      'credential_code': instance.credentialCode,
      'display_name': instance.displayName,
      'tier': instance.tier,
      'mode': instance.mode,
      'awarded_at': instance.awardedAt.toIso8601String(),
      'meta': instance.meta,
    };
