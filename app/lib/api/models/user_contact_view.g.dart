// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_contact_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserContactView _$UserContactViewFromJson(Map<String, dynamic> json) =>
    _UserContactView(
      userId: json['user_id'] as String,
      phoneE164: json['phone_e164'] as String?,
      timezone: json['timezone'] as String,
      quietHoursStart: json['quiet_hours_start'] as String,
      quietHoursEnd: json['quiet_hours_end'] as String,
    );

Map<String, dynamic> _$UserContactViewToJson(_UserContactView instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'phone_e164': instance.phoneE164,
      'timezone': instance.timezone,
      'quiet_hours_start': instance.quietHoursStart,
      'quiet_hours_end': instance.quietHoursEnd,
    };
