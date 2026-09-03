// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_topic_preference_upsert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationTopicPreferenceUpsert _$NotificationTopicPreferenceUpsertFromJson(
  Map<String, dynamic> json,
) => _NotificationTopicPreferenceUpsert(
  topic: json['topic'] as String,
  emailEnabled: json['email_enabled'] as bool? ?? true,
  inappEnabled: json['inapp_enabled'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationTopicPreferenceUpsertToJson(
  _NotificationTopicPreferenceUpsert instance,
) => <String, dynamic>{
  'topic': instance.topic,
  'email_enabled': instance.emailEnabled,
  'inapp_enabled': instance.inappEnabled,
};
