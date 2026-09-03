// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preference_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferenceUpdate _$NotificationPreferenceUpdateFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferenceUpdate(
  timezone: json['timezone'] as String?,
  quietHoursEnabled: json['quiet_hours_enabled'] as bool?,
  quietStartLocal: json['quiet_start_local'] as String?,
  quietEndLocal: json['quiet_end_local'] as String?,
  channelEmailEnabled: json['channel_email_enabled'] as bool?,
  channelInappEnabled: json['channel_inapp_enabled'] as bool?,
  digestMode: json['digest_mode'] == null
      ? null
      : NotificationDigestMode.fromJson(json['digest_mode'] as String),
);

Map<String, dynamic> _$NotificationPreferenceUpdateToJson(
  _NotificationPreferenceUpdate instance,
) => <String, dynamic>{
  'timezone': instance.timezone,
  'quiet_hours_enabled': instance.quietHoursEnabled,
  'quiet_start_local': instance.quietStartLocal,
  'quiet_end_local': instance.quietEndLocal,
  'channel_email_enabled': instance.channelEmailEnabled,
  'channel_inapp_enabled': instance.channelInappEnabled,
  'digest_mode': instance.digestMode,
};
