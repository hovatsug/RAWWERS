// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_access_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientAccessResponse _$ClientAccessResponseFromJson(
  Map<String, dynamic> json,
) => _ClientAccessResponse(
  enabled: json['enabled'] as bool,
  reason: json['reason'] as String,
  waitlistAvailable: json['waitlist_available'] as bool? ?? true,
);

Map<String, dynamic> _$ClientAccessResponseToJson(
  _ClientAccessResponse instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'reason': instance.reason,
  'waitlist_available': instance.waitlistAvailable,
};
