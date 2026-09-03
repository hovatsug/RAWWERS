// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_topic_preference_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationTopicPreferenceView _$NotificationTopicPreferenceViewFromJson(
  Map<String, dynamic> json,
) => _NotificationTopicPreferenceView(
  topic: json['topic'] as String,
  emailEnabled: json['email_enabled'] as bool,
  inappEnabled: json['inapp_enabled'] as bool,
);

Map<String, dynamic> _$NotificationTopicPreferenceViewToJson(
  _NotificationTopicPreferenceView instance,
) => <String, dynamic>{
  'topic': instance.topic,
  'email_enabled': instance.emailEnabled,
  'inapp_enabled': instance.inappEnabled,
};
