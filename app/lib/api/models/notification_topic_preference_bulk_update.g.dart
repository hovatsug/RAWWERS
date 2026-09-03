// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_topic_preference_bulk_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationTopicPreferenceBulkUpdate
_$NotificationTopicPreferenceBulkUpdateFromJson(Map<String, dynamic> json) =>
    _NotificationTopicPreferenceBulkUpdate(
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => NotificationTopicPreferenceUpsert.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$NotificationTopicPreferenceBulkUpdateToJson(
  _NotificationTopicPreferenceBulkUpdate instance,
) => <String, dynamic>{'items': instance.items};
