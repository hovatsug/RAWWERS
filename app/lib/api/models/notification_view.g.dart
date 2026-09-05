// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationView _$NotificationViewFromJson(Map<String, dynamic> json) =>
    _NotificationView(
      id: json['id'] as String,
      topic: json['topic'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      action: json['action'] == null
          ? null
          : NotificationAction.fromJson(json['action'] as Map<String, dynamic>),
      severity: NotificationSeverity.fromJson(json['severity'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationViewToJson(_NotificationView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'action': instance.action,
      'severity': instance.severity,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };
