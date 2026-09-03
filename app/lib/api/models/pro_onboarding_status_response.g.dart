// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_onboarding_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProOnboardingStatusResponse _$ProOnboardingStatusResponseFromJson(
  Map<String, dynamic> json,
) => _ProOnboardingStatusResponse(
  proUserId: json['pro_user_id'] as String,
  status: ProOnboardingStatus.fromJson(json['status'] as String),
  currentCity: json['current_city'] as Map<String, dynamic>?,
  inviteCodeId: json['invite_code_id'] as String?,
  notes: json['notes'] as String?,
  startedAt: DateTime.parse(json['started_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProOnboardingStatusResponseToJson(
  _ProOnboardingStatusResponse instance,
) => <String, dynamic>{
  'pro_user_id': instance.proUserId,
  'status': instance.status,
  'current_city': instance.currentCity,
  'invite_code_id': instance.inviteCodeId,
  'notes': instance.notes,
  'started_at': instance.startedAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
