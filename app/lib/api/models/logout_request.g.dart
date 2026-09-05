// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LogoutRequest _$LogoutRequestFromJson(Map<String, dynamic> json) =>
    _LogoutRequest(
      refreshToken: json['refresh_token'] as String?,
      revokeFamily: json['revoke_family'] as bool? ?? false,
    );

Map<String, dynamic> _$LogoutRequestToJson(_LogoutRequest instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
      'revoke_family': instance.revokeFamily,
    };
