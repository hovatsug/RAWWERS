// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => _MeResponse(
  userId: json['user_id'] as String,
  email: json['email'] as String?,
  emailVerifiedAt: json['email_verified_at'] == null
      ? null
      : DateTime.parse(json['email_verified_at'] as String),
  status: json['status'] as String,
  roles: (json['roles'] as List<dynamic>?)
      ?.map((e) => UserRoleType.fromJson(e as String))
      .toList(),
  locale: json['locale'] as String? ?? 'en-GB',
  isImpersonating: json['is_impersonating'] as bool? ?? false,
  impersonationAdminUserId: json['impersonation_admin_user_id'] as String?,
);

Map<String, dynamic> _$MeResponseToJson(_MeResponse instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
      'status': instance.status,
      'roles': instance.roles,
      'locale': instance.locale,
      'is_impersonating': instance.isImpersonating,
      'impersonation_admin_user_id': instance.impersonationAdminUserId,
    };
