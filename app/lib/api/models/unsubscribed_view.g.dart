// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsubscribed_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnsubscribedView _$UnsubscribedViewFromJson(Map<String, dynamic> json) =>
    _UnsubscribedView(
      topic: json['topic'] as String,
      unsubscribed: json['unsubscribed'] as bool,
    );

Map<String, dynamic> _$UnsubscribedViewToJson(_UnsubscribedView instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'unsubscribed': instance.unsubscribed,
    };
