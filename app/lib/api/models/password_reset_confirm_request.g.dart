// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_confirm_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PasswordResetConfirmRequest _$PasswordResetConfirmRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordResetConfirmRequest(
  code: json['code'] as String,
  newPassword: json['new_password'] as String,
);

Map<String, dynamic> _$PasswordResetConfirmRequestToJson(
  _PasswordResetConfirmRequest instance,
) => <String, dynamic>{
  'code': instance.code,
  'new_password': instance.newPassword,
};
