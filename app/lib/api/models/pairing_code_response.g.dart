// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PairingCodeResponse _$PairingCodeResponseFromJson(Map<String, dynamic> json) =>
    _PairingCodeResponse(
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      validMinutes: (json['valid_minutes'] as num).toInt(),
    );

Map<String, dynamic> _$PairingCodeResponseToJson(
  _PairingCodeResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'expires_at': instance.expiresAt.toIso8601String(),
  'valid_minutes': instance.validMinutes,
};
