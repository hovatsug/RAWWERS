// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_contact_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserContactUpdateRequest _$UserContactUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _UserContactUpdateRequest(
  phoneE164: json['phone_e164'] as String?,
  timezone: json['timezone'] as String?,
  quietHoursStart: json['quiet_hours_start'] as String?,
  quietHoursEnd: json['quiet_hours_end'] as String?,
);

Map<String, dynamic> _$UserContactUpdateRequestToJson(
  _UserContactUpdateRequest instance,
) => <String, dynamic>{
  'phone_e164': instance.phoneE164,
  'timezone': instance.timezone,
  'quiet_hours_start': instance.quietHoursStart,
  'quiet_hours_end': instance.quietHoursEnd,
};
